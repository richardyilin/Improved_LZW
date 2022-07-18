clc;
clear;
close all;

bit_look_ahead = 4;
bit_search_window = 12;
file_names = ["Freakconomics" "Harry_Potter" "Rich_Dad_Poor_Dad" "To_Kill_a_Mocking_Bird" "Good_to_Great" "Sophies_World"];
for name = file_names
    file_name = strcat("../../Test_patterns/", name, ".txt");
    fileID = fopen(file_name,'r');
    seq = fscanf(fileID,'%c');
    fclose(fileID);
    searchWindowLen = mpower(2,bit_search_window) - 1;
    lookAheadWindowLen = mpower(2,bit_look_ahead) - 1;
    seq=[seq,char(0)];        
    seq_len = length(seq);
    code=encode(seq,searchWindowLen,lookAheadWindowLen);

    decoded=decode(code,searchWindowLen,lookAheadWindowLen);
    code_len = length(code);
    rate = code_len/seq_len;
    correct = isequal(seq,decoded);
    assert(correct,'Decode incorrectly\nfile path %s\n', file_name);
    fprintf('Decoding correctness %d\n', correct);
    fprintf('Length of the code %d\n', code_len);
    fprintf('Length of the seqence %d\n', length(seq));
    fprintf('Compression ratio %f\n', rate);
end

function result=returnPartOfString(str,startindex,endindex)
    result=str(1,startindex:endindex);
end

function decompressed=decode(binaryStr,searchWindowLen,lookAheadWindowLen)
    decompressed='';
    bytenumSW=length(dec2bin(searchWindowLen));
    bytenumLA=length(dec2bin(lookAheadWindowLen));
    i=1;
    while i<length(binaryStr)
        LA = returnPartOfString(binaryStr,i,i-1+bytenumLA);
        LAdec = bin2dec(LA);
        i = i + bytenumLA;
        if(LAdec~=0)
            SW=returnPartOfString(binaryStr,i,i-1+bytenumSW);
            SWdec=bin2dec(SW);
            i=i+bytenumSW;
        else
            SWdec=0;
        end

        Chr=returnPartOfString(binaryStr,i,i-1+7);
        Chrch=char(bin2dec(Chr));
        i=i+7;
        if(SWdec==0)
            decompressed=strcatNew(decompressed,Chrch);
        else
            location=length(decompressed)-SWdec;
            for j=1:LAdec
                decompressed=strcatNew(decompressed,decompressed(location+j));

            end
            decompressed=strcatNew(decompressed,Chrch);
        end    
    end
end
function compressed=encode(str,searchWindowLen,lookAheadWindowLen)
    compressed='';
    i=1;
    while i<=length(str)
        startindex=i-searchWindowLen;
        if(startindex)<1
            startindex=1;
        end        
        endindex=i+lookAheadWindowLen-1;
        if(endindex)>length(str)
            endindex=length(str);
        end        
        searchBuffer= returnPartOfString(str,startindex,endindex);        
        lookAheadBuffer=returnPartOfString(str,i,endindex);
        j=1;
        tobesearched=returnPartOfString(lookAheadBuffer,1,j);
        searchresult=strfind(searchBuffer,tobesearched);
        if(numel(lookAheadBuffer) > j)            
            while (searchresult(1,1)<= (i-startindex))
                j=j+1;
                if(j<=length(lookAheadBuffer))
                    tobesearched=returnPartOfString(lookAheadBuffer,1,j);
                    searchresult=strfind(searchBuffer,tobesearched);
                else
                    break;
                end
            end
        end
        if (j>1)
            tobesearched=returnPartOfString(lookAheadBuffer,1,j-1);
            searchresult=strfind(searchBuffer,tobesearched);
        end
        if(searchresult(1,1)<= (i-startindex))
            occur = length(searchBuffer) - (endindex-i) - searchresult(1,1);
        else
            occur=0;
        end

        bytenumSW=length(dec2bin(searchWindowLen));
        bytenumLA=length(dec2bin(lookAheadWindowLen));
        if(occur~=0)
            compressed=strcatNew(compressed,dec2bin(j-1,bytenumLA));
            compressed=strcatNew(compressed,dec2bin(occur,bytenumSW));
            compressed=strcatNew(compressed,dec2bin(str(i+j-1)-0,7));
        else
            compressed=strcatNew(compressed,dec2bin(0,bytenumLA));
            compressed=strcatNew(compressed,dec2bin(str(i)-0,7));
        end
        i=i+j;
    end
end

function str=strcatNew(first,second)
    str=[first second];
end