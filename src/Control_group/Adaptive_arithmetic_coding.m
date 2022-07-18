close all;
clc;
clear;
symbol = '';
for i = 1 : 128
    symbol(1,i) = char(i-1);
end
file_names = ["Freakconomics" "Harry_Potter" "Rich_Dad_Poor_Dad" "To_Kill_a_Mocking_Bird" "Good_to_Great" "Sophies_World"];
for name = file_names
    file_name = strcat("../../Test_patterns/", name, ".txt");
    fileID = fopen(file_name,'r');
    seq = fscanf(fileID,'%c');
    fclose(fileID);
    code = arithmetic_encoding(symbol,seq);
    string = arithmetic_decoding(symbol,length(seq),code);
    correct = strcmp(seq,string);
    assert(correct);
    code_len = length(code) + ceil(log2(length(seq)));
    rate = code_len / length(seq);
    assert(correct,'Decode incorrectly\nfile path %s\n', file_name);
    fprintf('Decoding correctness %d\n', correct);
    fprintf('Length of the code %d\n', code_len);
    fprintf('Length of the seqence %d\n', length(seq));
    fprintf('Compression ratio %f\n', rate);
end

function code = arithmetic_encoding(symbol, seq)
    accum = ones(1,length(symbol));
    total = length(symbol);
    prob = accum / total; 
    lower = 0;
    upper = 1;
    code = '';
    for i = 1 : length(seq)
        S=zeros(1,length(symbol)+1);
        for j=2:length(symbol)+1
            S(1,j)=S(1,j-1)+prob(1,j-1);
        end
        index = find(seq(i) == symbol);
        lower_new = lower + (upper - lower) * S(index);
        upper_new = lower + (upper - lower) * S(index+1);
        lower = lower_new;
        upper = upper_new;
        while((upper <= 0.5 && lower <= 0.5) || (lower >= 0.5 && upper >= 0.5))
            if (upper <= 0.5 && lower <= 0.5)
                code = strcat(code,'0');
                lower = lower * 2;
                upper = upper * 2;                    
            elseif (lower >= 0.5 && upper >= 0.5)
                code = strcat(code,'1');
                lower = lower * 2 - 1;
                upper = upper * 2 - 1;                    
            end
        end        
        accum(1,index) = accum(1,index) + 1;
        total = total + 1;          
        if total >= mpower(2,31)            
            accum = ceil(accum/2);  
            total = sum(accum);
        end    
        prob = accum / total;
    end  
    b = 2;
    while(1)
        c = ceil(lower * mpower(2,b));
        if ((c+1) * mpower(2,-b) <= upper)
            break
        end
        b = b + 1;
    end
    code = strcat(code, dec2bin(c,b));
end
function string = arithmetic_decoding(symbol, N, code) %N is the length of data
    string = '';
    accum = ones(1,length(symbol));
    total = length(symbol);
    prob = accum / total; 
    lower = 0;
    upper = 1;
    lower1 = 0;
    upper1 = 1;
    S=zeros(1,length(symbol)+1);
    for j=2:length(symbol)+1
        S(1,j)=S(1,j-1)+prob(1,j-1);
    end
    bit_index = 1;
    current_code_length = 0;
    while(current_code_length < N)
        bit = code(1,bit_index);
        bit_index = bit_index + 1;
        if bit == '1'
            lower1 = lower1 + (upper1 - lower1)/2;
        elseif bit == '0'
            upper1 = lower1 + (upper1 - lower1)/2;
        end
        in_range = true;
        while(in_range)
            in_range = false;
            for index = 1 : length(symbol)
                lower2 = lower + (upper - lower) * S(1,index);
                upper2 = lower + (upper - lower) * S(1,index+1); 
                if(lower2 <= lower1 && upper2 >= upper1)
                    in_range = true;
                    string = [string,symbol(1,index)];
                    lower = lower2;
                    upper = upper2;
                    accum(1,index) = accum(1,index) + 1;
                    total = total + 1;        
                    if total >= mpower(2,31)           
                        accum = ceil(accum/2);   
                        total = sum(accum);
                    end    
                    prob = accum / total;
                    for j=2:length(symbol)+1
                        S(1,j)=S(1,j-1)+prob(1,j-1);
                    end
                    current_code_length = current_code_length + 1;
                    while((upper <= 0.5 && lower <= 0.5) || (lower >= 0.5 && upper >= 0.5))
                        if (upper <= 0.5 && lower <= 0.5)
                            lower = lower * 2;
                            upper = upper * 2;
                            lower1 = lower1 * 2;
                            upper1 = upper1 * 2;
                        elseif (lower >= 0.5 && upper >= 0.5)
                            lower = lower * 2 - 1;
                            upper = upper * 2 - 1;
                            lower1 = lower1 * 2 - 1;
                            upper1 = upper1 * 2 - 1;
                        end
                    end
                    break;
                end   
            end
        end        
    end
end