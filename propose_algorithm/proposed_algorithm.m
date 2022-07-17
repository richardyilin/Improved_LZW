close all;
clc;
clear;
file_name = '../FreakconomicsTestPattern.txt';
%file_name = '../HarryTestPattern.txt';
%file_name = '../RichDadTestPattern.txt';
%file_name = '../ToKillAMockingbirdTestPattern.txt';
%file_name = '../GoodToGreatTestPattern.txt';
%file_name = '../SophieTestPattern.txt';
fileID = fopen(file_name,'r');
lzwInput = fscanf(fileID,'%c');
fclose(fileID);
bit_per_code = 12;
threshold = 2;
maxTableSize = mpower(2,bit_per_code);
[lzwOutput, lzwTable,real_table] = norm2lzw(lzwInput,maxTableSize,false,threshold);
[lzwOutputd, lzwTabled,decoded_real_table] = lzw2norm(lzwOutput,maxTableSize,false,threshold);
code_len = bit_per_code * length(lzwOutput);
rate = (code_len/length(lzwInput));
correct = isequal(lzwInput,lzwOutputd);   
array = find(lzwOutput > maxTableSize);
assert(correct,'decode incorrectly\nfile name %s\nbit_per_code %d\n',file_name,bit_per_code);
assert(isempty(array),'max size overflow\nindex %d',array);
fprintf('decoding correctness %d\n',correct);
fprintf('length of the code %d\nlength of the seqence %d\nratio %f\n',code_len,length(lzwInput),rate);
function [output, table,real_table] = norm2lzw (vector, maxTableSize, restartTable,threshold)
    
    vector = double(vector(:)');
    if (nargin < 2)
        maxTableSize = 4096;
        restartTable = 0;
    end
    if (nargin < 3)
        restartTable = 0;
    end

    table = newTable(maxTableSize,threshold); % it's original dictionary in the paper
    real_table = newRealTable(maxTableSize);  % it's improved dictionary in the paper
    output = zeros(1,length(vector));
    outputIndex = 1;
    lastCode = vector(1,1) + 1;
    lastCode_real = vector(1,1) + 1;
    for index=2:length(vector)
        code_real = findCodeReal(lastCode_real, vector(1,index),real_table);      
       
        if ~isempty(code_real)
            lastCode_real = code_real;
        else
            
            if real_table.codes(lastCode_real).born_index < index - real_table.codes(lastCode_real).codeLength
                output(1,outputIndex) = lastCode_real;
                outputIndex = outputIndex+1;
            else
               output(1,outputIndex) = real_table.codes(lastCode_real).lastCode;
               output(1,outputIndex+1) = real_table.codes(lastCode_real).c + 1;
               outputIndex = outputIndex+2;
            end            
            lastCode_real = vector(1,index) + 1;
        end 
        
        [code,table,real_table] = findCode(lastCode, vector(1,index),table,real_table,threshold,maxTableSize,index);
        if ~isempty(code)
            lastCode = code;
        else 
            if (real_table.nextCode <= maxTableSize)
                [table,real_table] = addCode_decode(lastCode, vector(1,index),table,real_table,threshold,maxTableSize);
                if (restartTable && real_table.nextCode == maxTableSize+1)
                    table = newTable(maxTableSize,threshold);
                    real_table = newRealTable(maxTableSize);
                end
            end
            lastCode = vector(1,index) + 1;
        end    
    end
    if real_table.codes(lastCode_real).born_index < index - real_table.codes(lastCode_real).codeLength
        output(1,outputIndex) = lastCode_real;
        outputIndex = outputIndex+1;
    else
       output(1,outputIndex) = real_table.codes(lastCode_real).lastCode;
       output(1,outputIndex+1) = real_table.codes(lastCode_real).c + 1;
       outputIndex = outputIndex+2;
    end 
    output = output(1,1:(outputIndex-1));
    table.codes = table.codes(1:table.nextCode-1);
    real_table.codes = real_table.codes(1:real_table.nextCode-1);
end
function code = findCodeReal(in_lastCode, c,in_real_table)
    candidate_index = in_real_table.codes(in_lastCode).prefix;
    real_index = find([in_real_table.codes(candidate_index).c] == c,1);
    code = candidate_index(real_index);
end
function [code,out_table,out_real_table] = findCode(in_lastCode, c,in_table,in_real_table,threshold,maxTableSize,index)
    out_table = in_table;
    candidate_index = in_table.codes(in_lastCode).prefix;
    real_index = find([in_table.codes(candidate_index).c] == c,1);
    code = candidate_index(real_index);    
    out_real_table = in_real_table;
    if ~isempty(code)
        if out_table.codes(code).frequency <= threshold
            out_table.codes(code).frequency = out_table.codes(code).frequency + 1;
        end
        if out_table.codes(code).frequency == threshold && in_real_table.nextCode <= maxTableSize
            add_real.c = in_table.codes(code).c;
            add_real.lastCode = in_table.codes(in_lastCode).index_real;
            add_real.codeLength = in_table.codes(code).codeLength;
            add_real.prefix = [];
            add_real.born_index = index;
            out_real_table.codes(out_real_table.nextCode) = add_real;
            out_real_table.codes(in_table.codes(in_lastCode).index_real).prefix = ...
            [out_real_table.codes(in_table.codes(in_lastCode).index_real).prefix,out_real_table.nextCode];
            out_table.codes(code).index_real = out_real_table.nextCode; % the index of such string in the real table
            out_real_table.nextCode = out_real_table.nextCode + 1;
        end 
    end
end
function [out_table,out_real_table] = addCode_decode(lastCode, c,in_table,in_real_table,threshold, maxTableSize)
    out_table = in_table;
    e.c = c;
    e.lastCode = lastCode;
    e.prefix = [];
    e.codeLength = in_table.codes(lastCode).codeLength + 1;
    e.frequency = 1;
    e.index_real = -1;
    out_table.codes(out_table.nextCode) = e;
    out_table.codes(lastCode).prefix = [out_table.codes(lastCode).prefix, out_table.nextCode];
    out_real_table = in_real_table;
    if threshold <= 1 && in_real_table.nextCode <= maxTableSize
        add_real.c = c;
        add_real.lastCode = out_table.codes(lastCode).index_real;
        add_real.codeLength = out_table.codes(lastCode).codeLength + 1;
        add_real.prefix = [];
        out_real_table.codes(out_real_table.nextCode) = add_real;
        out_real_table.codes(out_table.codes(lastCode).index_real).prefix = ...
        [out_real_table.codes(out_table.codes(lastCode).index_real).prefix,out_real_table.nextCode];
        out_table.codes(out_table.nextCode).index_real = out_real_table.nextCode; % the index of such string in the real table
        out_real_table.nextCode = out_real_table.nextCode + 1;
    end
    out_table.nextCode = out_table.nextCode + 1; 
end
function [output,table,real_table] = lzw2norm (vector, maxTableSize, restartTable,threshold)
    
    vector = vector(:)';

    if (nargin < 2)
        maxTableSize = 4096;
        restartTable = 0;
    end
    if (nargin < 3)
        restartTable = 0;
    end
    table = newTable(maxTableSize,threshold); % it's original dictionary in the paper
    real_table = newRealTable(maxTableSize);  % it's improved dictionary in the paper
    output = zeros(1, 3*length(vector));
    outputIndex = 1;
    output(1,outputIndex) = table.codes(vector(1,1)).c;
    outputIndex = outputIndex + 1;
    original_lastCode = table.codes(vector(1,1)).c + 1;
    for vectorIndex=2:length(vector)
        element = vector(1,vectorIndex);
        assert(element < real_table.nextCode)
        str = getCode(element,real_table);
        output(1,outputIndex + (0:length(str)-1)) = str;
        for index=outputIndex:outputIndex+length(str)-1
            [code,table,real_table] = findCode(original_lastCode, output(1,index),table,real_table,threshold,maxTableSize,index);
            if ~isempty(code)
                original_lastCode = code;
            else
                if (real_table.nextCode <= maxTableSize)
                    [table,real_table] = addCode_decode(original_lastCode, output(1,index),table,real_table,threshold,maxTableSize);
                    if (restartTable && real_table.nextCode == maxTableSize+1)
                        table = newTable(maxTableSize,threshold);
                        real_table = newRealTable(maxTableSize);
                    end
                end
                original_lastCode = output(1,index) + 1;
            end
        end
        outputIndex = outputIndex + length(str);
        if ((length(output)-outputIndex) < 1.5*(length(vector)-vectorIndex))
            output = [output, zeros(1, 3*(length(vector)-vectorIndex))];
        end
        if (length(str) < 1)
            keyboard;
        end
    end

    output = output(1,1:outputIndex-1);
    table.codes = table.codes(1:table.nextCode-1);
    real_table.codes = real_table.codes(1:real_table.nextCode-1);
end
function str = getCode(code,in_table)
    l = in_table.codes(code).codeLength;
    str = zeros(1, l);
    for ii = l:-1:1
        str(ii) = in_table.codes(code).c;
        code = in_table.codes(code).lastCode;
    end
end

function table = newTable(maxTableSize,threshold)
    e.c = 0;
    e.lastCode = -1;
    e.prefix = [];
    e.codeLength = 1;
    e.frequency = 0;
    e.index_real = -1;
    table.nextCode = 2;
    if (~isinf(maxTableSize))
        table.codes(1:(maxTableSize*threshold)) = e;
    else
        table.codes(1:65536) = e;
    end
    for c = 1:127
        e.c = c;
        e.lastCode = -1;
        e.prefix = [];
        e.codeLength = 1;
        e.frequency = inf;
        e.index_real = c+1;
        table.codes(table.nextCode) = e;
        table.nextCode = table.nextCode + 1;
    end
    table.codes(1).frequency = inf;
    table.codes(1).index_real = 1;
end
function table = newRealTable(maxTableSize)
    e.c = 0;
    e.lastCode = -1;    
    e.prefix = [];
    e.codeLength = 1;
    e.born_index = -1;
    table.nextCode = 2;
    if (~isinf(maxTableSize))
        table.codes(1:maxTableSize) = e;
    else
        table.codes(1:65536) = e;
    end
    for c = 1:127
        e.c = c;
        e.lastCode = -1;
        e.prefix = [];
        e.codeLength = 1; 
        e.born_index = -1;
        table.codes(table.nextCode) = e;
        table.nextCode = table.nextCode + 1;
    end    
end