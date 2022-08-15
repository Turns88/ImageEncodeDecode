function [decodedImage] = decode(songFileName)

% Decode
%Takes an encoded song (.wav file) as an argument and
%returns an image file with the correct file format(eg .jpg,png etc)
% The decoded image is labelled decodedImage by default and is located
%in the enclosed folder. 
%In a 2 column stereo song, the right column holds all of the image data.
%The image data is then split either split into a single column for 
%black and white or grey scale photos or split into 3 columns for 
% colour images. For colour images the data is split into respective
%H/S/V columns, then reshaped
%into H/S/V Matrices based off the original dimensions also encoded in the
%song. The H/S/V Matrices are then combined to an original HSV image, 
%converted back to RGB and then finally the image is created in the
%enclosed folder with the correct file type which is also encoded in the 
%song.


%Read .wav file which is a 2 column stereo song
% Left column is the cover song Right column is image data

secretSong = audioread(songFileName);

%Seperate all of  the  image data from  the song  file
%All of  the image data is located in the  right  channel.
hiddenImage = secretSong(:,2);

%determine the length

hiddenImageLength = length(hiddenImage);

%extract last value to determine colour or non colour image

imageTypeNums = hiddenImage(length(secretSong)-1:end,1);

%delete that value from image data column

hiddenImage(length(secretSong)-1:end,:) = [];
hiddenImageLength = length(hiddenImage);

% decode  if colour  or non colour

imageTypeNums =  int16(imageTypeNums * 10000);

%The image and file type that is hidden as a double value is converted to 
%characters and then transposed to reveal the file type encoded. 
%3 letter system for file type
%2 letter system for image type

imageType = char(imageTypeNums);
imageType = imageType';

%extract the file type from the last 3 values of the image data
%when encoded the 3 letters designating the file type were converted
%from string to double to be compatible with the other data

fileTypeNums = hiddenImage(hiddenImageLength -2:end ,1);

%once the file type values have been extracted, remove the last 3 values
%from the image data column

hiddenImage(hiddenImageLength -2 :end ,:) = [];
hiddenImageLength = length(hiddenImage) ;

%extract the amount of columns the original image matrix had

numCols = hiddenImage(hiddenImageLength,1);

%delete that value from image data column

hiddenImage(hiddenImageLength,:) = [];

%extract the amount of rows the original image matrix had

numRows  = hiddenImage(hiddenImageLength - 1,1);

%delete that value from image data column

hiddenImage(hiddenImageLength -1,:) = [];
hiddenImageLength = length(hiddenImage);

%The rows and column dimensions of the original image matrix as well as the
%HSV values and file type were encoded as a double to be compatible
%with the other data types.
%When compared to song value the original double values caused background
%noise on the track %(eg original 0.768 vs song value 0.005)
%by multiplying and dividing by an easy big number there is no data loss
%and results in no audio interference.

numRows = int16(numRows * 10000);
numCols = int16(numCols * 10000);


%The file type that is a double is converted to characters and then 
%transposed to reveal the file type encoded. 
fileTypeNums =  int16(fileTypeNums * 10000);
fileType = char(fileTypeNums);
fileType = fileType';


if imageType == 'co'
    hiddenImage = hiddenImage * 100 ;

    
    %All the data thats left in the data column soley belongs to the image now
    %The amount of rows is calculated and then divided by 3 because the
    %H,S and V matrices all have equal amount of values.
    
    subArrayLength = hiddenImageLength / 3;
    

    %Seperate the  single HSV column into respective H/S/V columns by
    %using the 1/3 length of the HSV data column as an index to the original
    %HSV data column minus the extra encoded information.
    %eg H goes from start to 1/3, S from 1/3 to 2/3 and V 2/3 to end.
    
    decodedHArray = hiddenImage(1:subArrayLength);
    decodedSArray = hiddenImage(subArrayLength+1:subArrayLength + subArrayLength);
    decodedVArray =  hiddenImage(subArrayLength + subArrayLength + 1 :subArrayLength + subArrayLength + subArrayLength);
    
    
    %reshape single H/S/V columns  into their original matrix form by using
    %the decoded row and column dimensions. This is why those dimensions were
    % encoded to ensure the decoded matrix was exactly the same as the original
    
    decodedHMatrix =  reshape(decodedHArray,numRows,numCols);
    decodedSMatrix =  reshape(decodedSArray,numRows,numCols);
    decodedVMatrix =  reshape(decodedVArray,numRows,numCols);
    
    %add each  H/S/V matrix into a single 3 channel HSV image
    
    decodedHSV(:,:,1) = decodedHMatrix;
    decodedHSV(:,:,2) = decodedSMatrix;
    decodedHSV(:,:,3) = decodedVMatrix;
    
    %convert the completed HSV image  to an RGB image;
    
    decodedImage = hsv2rgb(decodedHSV);
    


%black and white image.

elseif imageType == 'bw'
    
    % if the image type is black and white it multiplies the image values
    % by the amount it was divided by in encoding.

    hiddenImage= hiddenImage * 100;
    
    %converts decimal number back to whole number
    
    hiddenImage = round(double(hiddenImage));
    
    %$Subtracts 1 to correct the 0,1 values from 2,1 back to 0,1.
    
    hiddenImage = hiddenImage -1;
    
    %change data type
    
    hiddenImage = uint8(hiddenImage);
    
    % recreate the original image matrix from the column of image data
    
    decodedImage =  reshape(hiddenImage,numRows,numCols);
    
    %black and white photos only work in a logical array format
    
    decodedImage  = logical(decodedImage);
    
%grey scale images

elseif imageType == 'gs'
    
    % if the image type is black and white it multiplies the image values
    % by the amount it was divided by in encoding.
    
    hiddenImage= hiddenImage * 10000;
    
    %converts decimal number back to whole number
    
    hiddenImage = round(double(hiddenImage));
    
     %Subtracts 1 to correct the 0,1 values from 2,1 back to 0,1.
     
    hiddenImage = hiddenImage -1;
    
    %change data type
    
    hiddenImage = uint8(hiddenImage);
    
    % recreate the original image matrix from the column of image data
    decodedImage =  reshape(hiddenImage,numRows,numCols);
    
    
    
end






%Due to a 3 character system
%being used the if statement corrects the additional file types with 
%4 characters. This is based off the most commenly used file types.



if endsWith(fileType, '.jpe') ==1
    
    fileType = 'jpeg';
    
elseif endsWith(fileType, 'tif') ==1
    
    fileType = 'tiff';
    
end

%default fileName for decoded image

fileName = 'decodedImage.';

%add decoded file type to the filename in preparation for writing

fileName = append(fileName,fileType);

%show decoded image in MATLAB for comparison

imshow(decodedImage);

%create the decoded image file in the enclosed folder

imwrite(decodedImage,fileName);

end

