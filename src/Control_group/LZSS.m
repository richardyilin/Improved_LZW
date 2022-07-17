clear;
close all;
clc;

bit_search_window = 12;
bit_look_ahead = 4;
for k = 1 : 6
     switch k
        case 1
            file_name = '../../Test_patterns/FreakconomicsTestPattern.txt';
        case 2
            file_name = '../../Test_patterns/HarryTestPattern.txt';
        case 3
            file_name = '../../Test_patterns/RichDadTestPattern.txt';
        case 4
            file_name = '../../Test_patterns/ToKillAMockingbirdTestPattern.txt';
        case 5
            file_name = '../../Test_patterns/GoodToGreatTestPattern.txt';
        case 6
            file_name = '../../Test_patterns/SophieTestPattern.txt';
     end
    fileID = fopen(file_name,'r');
    seq = fscanf(fileID,'%c');
    fclose(fileID);
    searchWindowLen = mpower(2,bit_search_window) - 1;
    lookAheadWindowLen = mpower(2,bit_look_ahead) - 1;
    seq_len = length(seq);
    code=encode(seq,searchWindowLen,lookAheadWindowLen);

    decoded=decode(code,searchWindowLen,lookAheadWindowLen);
    code_len = length(code);
    rate = code_len/seq_len;
    correct = isequal(seq,decoded);
    assert(correct);        
    fprintf('decoding correctness: %d\n',correct);
    fprintf('length of the code %d\nlength of the seqence %d\nratio %f\n',code_len,seq_len,rate);  
end

function result=returnPartOfString(str,startindex,endindex)
    result=str(1,startindex:endindex);
end

function decompressed=decode(binaryStr,searchWindowLen,lookAheadWindowLen)
    decompressed='';
    bytenumSW=length(dec2bin(searchWindowLen));
    bytenumLA=length(dec2bin(lookAheadWindowLen));
    bytenumFlag = 1;
    i=1;
    while i<length(binaryStr)
        flag = returnPartOfString(binaryStr,i,i-1+bytenumFlag) == '1';
        i = i + 1;
        
        if flag   
            LA = returnPartOfString(binaryStr,i,i-1+bytenumLA);
            LAdec = bin2dec(LA);
            i = i + bytenumLA;
            SW=returnPartOfString(binaryStr,i,i-1+bytenumSW);
            SWdec=bin2dec(SW);
            i=i+bytenumSW;
            location=length(decompressed)-SWdec;
            for j=1:LAdec
                decompressed=strcatNew(decompressed,decompressed(location+j));
            end               
        else
            dec_char = bin2dec(returnPartOfString(binaryStr,i,i-1+7));
            Character = char(dec_char);
            decompressed=strcatNew(decompressed,Character);
            i = i + 7;
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
        if(numel(lookAheadBuffer) >= j)            
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
            compressed=strcatNew(compressed,'1');
            compressed=strcatNew(compressed,dec2bin(j-1,bytenumLA));
            compressed=strcatNew(compressed,dec2bin(occur,bytenumSW));            
            i=i+j-1;
        else
            compressed=strcatNew(compressed,'0');
            compressed=strcatNew(compressed,dec2bin(str(i)-0,7));
            i = i + 1;
        end
    end
end
function str=strcatNew(first,second)
    str=[first second];
end