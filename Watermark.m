clc;
close all;
imtool close all; 
clear;  
workspace;  
fontSize = 12;
baseFileName='big.jpg';
folder = fullfile(matlabroot, '');
fullFileName = fullfile(folder, baseFileName);
if ~exist(fullFileName, 'file')
	fullFileName = baseFileName;
	if ~exist(fullFileName, 'file')
		errorMessage = sprintf('Error: %s does not exist.', fullFileName);
		uiwait(warndlg(errorMessage));
		return;
	end
end
originalImage = imread(fullFileName);
[visibleRows visibleColumns numberOfColorChannels] = size(originalImage);
if numberOfColorChannels > 1
	originalImage = originalImage(:,:,1);
end

subplot(3, 3, 4);
imshow(originalImage, []);
title('Original Grayscale Starting Image', 'FontSize', fontSize);

set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
set(gcf,'name','Demo by ImageAnalyst','numbertitle','off') 

baseFileName='small.jpg';

fullFileName = fullfile(folder, baseFileName);
if ~exist(fullFileName, 'file')
	
	fullFileName = baseFileName;
	if ~exist(fullFileName, 'file')
		
		errorMessage = sprintf('Error: %s does not exist.', fullFileName);
		uiwait(warndlg(errorMessage));
		return;
	end
end
hiddenImage = imread(fullFileName);

[hiddenRows hiddenColumns numberOfColorChannels] = size(hiddenImage);
if numberOfColorChannels > 1
	
	hiddenImage = hiddenImage(:,:,1);
end

subplot(3, 3, 1);
imshow(hiddenImage, []);
title('Image to be Hidden', 'FontSize', fontSize);

[pixelCount grayLevels] = imhist(hiddenImage);
subplot(3, 3, 2); 
bar(pixelCount);
title('Histogram of image to be hidden', 'FontSize', fontSize);
xlim([0 grayLevels(end)]);
grid on;
thresholdValue = 70;
binaryImage = hiddenImage < thresholdValue;
subplot(3, 3, 3);
imshow(binaryImage, []);
caption = sprintf('Hidden Image Thresholded at %d', thresholdValue);
title(caption, 'FontSize', fontSize);

prompt = 'Enter the bit plane you want to hide the image in (1 - 8) ';
dialogTitle = 'Enter Bit Plane to Replace';
numberOfLines = 1;
defaultResponse = {'6'};
bitToSet = str2double(cell2mat(inputdlg(prompt, dialogTitle, numberOfLines, defaultResponse)));

if hiddenRows > visibleRows || hiddenColumns > visibleColumns
	amountToShrink = min([visibleRows / hiddenRows, visibleColumns / hiddenColumns]);
	binaryImage = imresize(binaryImage, amountToShrink);
	
	[hiddenRows hiddenColumns] = size(binaryImage);
end

if hiddenRows < visibleRows || hiddenColumns < visibleColumns
	watermark = zeros(size(originalImage), 'uint8');
	for column = 1:visibleColumns
		for row = 1:visibleRows
			watermark(row, column) = binaryImage(mod(row,hiddenRows)+1, mod(column,hiddenColumns)+1);
		end
	end
	
	watermark = watermark(1:visibleRows, 1:visibleColumns);
else
	
	watermark = binaryImage;
end

subplot(3, 3, 5);
imshow(watermark, []);
caption = sprintf('Hidden Image\nto be Inserted into Bit Plane %d', bitToSet);
title(caption, 'FontSize', fontSize);

watermarkedImage = originalImage; 
for column = 1 : visibleColumns
	for row = 1 : visibleRows
		watermarkedImage(row, column) = bitset(originalImage(row, column), bitToSet, watermark(row, column));
	end
end

subplot(3, 3, 6);
imshow(watermarkedImage, []);
caption = sprintf('Final Watermarked Image\nwithout added Noise');
title(caption, 'FontSize', fontSize);
noisyWatermarkedImage = imnoise(watermarkedImage,'gaussian', 0, 0.0005);
subplot(3, 3, 7);
imshow(noisyWatermarkedImage, []);
caption = sprintf('Watermarked Image\nwith added Noise');
title(caption, 'FontSize', fontSize);

recoveredWatermark = zeros(size(noisyWatermarkedImage));
recoveredNoisyWatermark = zeros(size(noisyWatermarkedImage));
for column = 1:visibleColumns
	for row = 1:visibleRows
		recoveredWatermark(row, column) = bitget(watermarkedImage(row, column), bitToSet);
		recoveredNoisyWatermark(row, column) = bitget(noisyWatermarkedImage(row, column), bitToSet);
	end
end
recoveredWatermark = uint8(255 * recoveredWatermark);
recoveredNoisyWatermark = uint8(255 * recoveredNoisyWatermark);
subplot(3, 3, 8);
imshow(recoveredWatermark, []);
caption = sprintf('Watermark Recovered\nfrom Bit Plane %d of\nNoise-Free Watermarked Image', bitToSet);
title(caption, 'FontSize', fontSize);
subplot(3, 3, 9);
imshow(recoveredNoisyWatermark, []);
caption = sprintf('Watermark Recovered\nfrom Bit Plane %d of\nNoisy Watermarked Image', bitToSet);
title(caption, 'FontSize', fontSize);
msgbox('Done with demo!');