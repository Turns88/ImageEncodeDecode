function [] = encode(image2Encode,userSongName)

% ENCODE
%  This function takes an image and filename as arguments and then encodes
% all of the image data into a .wav file. While the function doesnt return 
%a value it creates a .wav file that is saved with the user
% entered filename which is located in the enclosed folder.
%It can take colour images or black and white greyScale images. For
% BW/grey scale it takes the single image matrix, transposes it into a
% single column of data along with additional information such as file
%type and data Type. Converts the image data type and shrinks the values 
%to prevent noise interfereing with the cover song
%For colour, it takes a 3 channel RGB, Converts it to HSV, seperates each 
%channel into columns, concatinates these columns to form a singular HSV 
%column This becomes the right column of a stereo 2 column stereo song. 
%The left column replicates a dummy song enough times to match the right 
%columnAny background noise caused by image data is then reduced and the 
%image is hidden in plain sight without any data loss. Additioinal
%information encoded includes image matrix dimensions and original image file type.



%Load image data from user that requires encoding

image = imread(image2Encode);


%Load the cover song that will be used to hide the image data

load  handel.mat;

%Store the filename of the image to be encoded.
imageName = string(image2Encode);

%Common file types are: '.jpg', '.jpeg','.png','.gif','.bmp','.raw','.tiff'

%Reads the original filename of the image to be encoded. Stores the file
%type as a 3 letter code these will be encoded later along with the HSV
%data and matrix dimensions. On decode if the original file type is 4
%characters it will be amended then.

if endsWith(imageName, '.jpg') == 1
    imageFileType = 'jpg'; 
    
elseif endsWith(imageName, '.jpeg') == 1
    imageFileType = 'jpe';
    
elseif endsWith(imageName, '.png') == 1
    imageFileType = 'png';
    
elseif endsWith(imageName, '.gif') == 1
    imageFileType = 'gif';
    
elseif endsWith(imageName, '.bmp') == 1
    imageFileType = 'bmp';
    
elseif endsWith(imageName, '.raw') == 1
    imageFileType = 'raw';
    
elseif endsWith(imageName, '.tiff') == 1
    imageFileType = 'tif';
    
else 
    imageFileType = 'png';  
end
    
%File Type characters are converted to double and then reduced to a smaller
%decimal value. This will prevent data clipping when the song is written.
%double is used because it is the data type of a sound file.

fileTypeNumbers = double(imageFileType);
fileTypeNumbersReduced = fileTypeNumbers /10000;

%Determine the length(how many columns the original sound is)
song = y;
songLength = length(song);



%Check if the image has more than  1  channel. If it
%has 3 it is  colour if it has one it is either greyscale or BW.

[numRows,numCols,numChans] = size(image);

if numChans  == 1
    %o for other type - non colour
        if islogical(image) == 1
            imageType = 'bw';
        else
            imageType = 'gs';
        end
        
        %encode image type by converting it to a double and making it a
        %really small number so it hides  well in the song
        
        imageTypeNumbers = double(imageType);
        imageTypeNumbersReduced = imageTypeNumbers /10000;
        
        %determine the total amount of values present in the image
        nonColourImageValues = numRows * numCols;
        
        %create a temp arrray the length of the image data but with 7 extra
        %spaces to hide, numRows, numCols, fileType(3 letter code,
        %imageType(2 letter code)
        
        a =  zeros(nonColourImageValues +  7,1);
        
       
        image = image +1;
        
        %black and white photos are 0 and 1 to make it smalleer and 
        %change it to a double  leads to divide by zero error. 
        %divide zero by anything
        %it was cause an error so by adding 1 it changes the values to 1,2
        % this step will be reversed on decode to obtain the original
        %value.
        
       nonColourImageArray(:,:,1) = reshape(image,nonColourImageValues,1);
        
       convertedNonColourImageHeight  = numRows / 10000;
       convertedNonColourImageLength = numCols /10000;
    
    % divide the image data values by 100. Data will be clipped when the
    % is soiund values are outside the -1 to 1 range. Also if the number is
    % decimal but to big it will create background noise heard through
    % the cover song. Dividing values reduces this noise and will be 
    %reversed on decode.
    %This will also hide the image data if the song is plotted.
    
    %created the modified array but with different reduction values 
    %this is because a bw pic will only have 1/0 values where as
    %greyscale will ahve values from 0 - 255
    
    aModded = double(nonColourImageArray);
    if imageType == 'gs'  
    aModded = aModded / 10000;   
    elseif imageType  =='bw'
    aModded = aModded / 100;
    end
    
    % encode row length as last value in the image data
    
    aModded(end+1,1) = convertedNonColourImageHeight;
    
    % encode column length as  the  last value in  the  image data
    
    aModded(end+1,1) = convertedNonColourImageLength;
    
    %encode fileName as the last 3 numbers
    
    aModded(end+1:end+3,1)  = fileTypeNumbersReduced;
    
    aModded(end+1:end+2,1) = imageTypeNumbersReduced;
    
elseif numChans == 3 
    
    %3 channels indicate a colour image in RGB form.
    
    %co for colour
        imageType = 'co';
        imageTypeNumbers = double(imageType);
        imageTypeNumbersReduced = imageTypeNumbers /10000;
    
    %%%%%%
    % convert RGB image  to HSV
    % this is because song data and HSV data is  the same data  type - double
    %Where as RGB is unit8
    
    possibleHSV = rgb2hsv(image);
    
    % seperate channels of  the HSV matrix
    
    h = (possibleHSV(:,:,1));
    s = (possibleHSV(:,:,2));
    v = (possibleHSV(:,:,3));
    
    
    % Determine how many rows and how many columns
    
    hsvHeight= size(possibleHSV,1);
    hsvLength = size(possibleHSV,2);
    
    % Determine the total number of  values each H/S/V matrix has
    
    totalHSVValues = hsvHeight * hsvLength;
    
    % Convert the  amount of rows and columns to a smaller decimal number.
    % This will allow  us  to hide the row and column numbers  as the last two
    % values in the  image data as well as reducing noise interference and
    %data clipping.
    
    convertedHSVHeight  = hsvHeight / 10000;
    convertedHSVLength = hsvLength /10000;
    
    % Determine the  total number  of values in  the image
    
    combinedHSVValues = totalHSVValues *3;
    
    %
    % Seperate the  single HSV column into respective
    % H/S/V columns
    
    hArray(:,:,1) = reshape(h,totalHSVValues,1);
    sArray(:,:,1) = reshape(s,totalHSVValues,1);
    vArray(:,:,1) = reshape(v,totalHSVValues,1);
    
    % add all  these columns together into a single column
    
    hsvArray = cat(1,hArray,sArray,vArray);
    
    % create a  new array to store all of the image values + 2 places
    % for the amount of rows and columns
    
    % +5 to include encoded 3 letter  fileType and amount of rows and columns.
    
    a =  zeros(combinedHSVValues +  7,1);
    
    


    
    % divide the HSV data values by 100. Data will be clipped when the song
    %is written if the values are outside -1,1. Dividing by 100 resulted in
    %no loss of data between encode and decode and dramatically reduced the
    %background noise allowing the data to hide in plain sight.
    %This will reduce their value eg from 0.5 to  0.005 .
    %This will also hide the image data if the song is plotted.
    
    aModded = hsvArray / 100;
    
    % encode row length as last value in the image data
    
    aModded(end+1,1) = convertedHSVHeight;
    
    % encode column length as  the  last value in  the  image data
    
    aModded(end+1,1) = convertedHSVLength;
    
    %encode fileName as the last 3 numbers
    
    aModded(end+1:end+3,1)  = fileTypeNumbersReduced;
    
    aModded(end+1:end+2,1) = imageTypeNumbersReduced;
    
end

% Scale factor for how many times the song rows fits into the total image
% rows. This sometimes led to unusual results due to a decimal result.
%by converting to an integer and rounding down means
%consistant conversion no matter the size of the image column.

extendedSongScaleFactor = (int16(length(a) / songLength))  -1;

%A newer longer cover song is created by repeating the smaller song
%as many times as it will fit fully into the same rows as all of the 
%HSV data that will be in the HSV column later.

bigSong = repmat(song,extendedSongScaleFactor,1);


extendedSongLength = length(bigSong);

%a is then filled with the extended cover song values
a(1:extendedSongLength,1) = bigSong;

%detimine the difference between the entire empty array a and the 
%length of the extended cover song

bigSongDiff = length(a) - length(bigSong);

%Determine if there is any gaps of silence at the end of the array which
%will lead to possible compromise of the secret image. If there is gaps
%it is covered with a modifed smaller version of the song that is 
%is determined by the gap.

if bigSongDiff > songLength
    a(extendedSongLength +1:extendedSongLength +songLength,1) = song;

else 
    smallSong = song(1:bigSongDiff);
    a(extendedSongLength +1:end,1) = smallSong;
end


% Left column of the .wav stereo song is the cover song. Replicated as 
%many times as needed to cover the length of the HSV. Although padding 
%with zeros is an option, the objective of steganography is to hide in 
%plain sight. An annoying repeating song is not as obvious as minutes
%of silent .wav file where a use may pick up on random background noise.

FinalArray(:,1) = a;

% Right  column of the .wav file contains all of the image data without
%any loss, the dimensions m X n of the original image matrix and the
%file type converted to double.

FinalArray(:,2) = aModded;

%check for valid user input for encoded song name otherwise
%have a default

if userSongName == ""
    userSongName = 'toHotToHandel';   
end



% This if statement checks if the name the user provided ends in ".wav"
% If it does not then it'll add .wav to the end of the string.

pattern = ".wav";
endswithwav = endsWith(userSongName, pattern);
if endswithwav == 0
      
    userSongName = userSongName + pattern;

end

% write the final array to .wav file using the user provdied file name
%this is stored in the enclosed folder soyou can listen on a music player.

audiowrite(userSongName,FinalArray,Fs);

end

