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
maxTableSize = mpower(2,bit_per_code);
[lzwOutput, lzwTable] = norm2lzw(lzwInput,maxTableSize,false);
[lzwOutputd, lzwTabled] = lzw2norm(lzwOutput,maxTableSize,false);
code_len = bit_per_code * length(lzwOutput);
rate = (code_len/length(lzwInput));
correct = isequal(lzwInput,lzwOutputd);
assert(correct,'decode incorrectly\nfile name %s\n',file_name);
fprintf('decoding correctness %d\n',correct);
fprintf('length of the code %d\nlength of the seqence %d\nratio %f\n',code_len,length(lzwInput),rate);
function [output, table] = norm2lzw (vector, maxTableSize, restartTable)

vector = double(vector(:)');

if (nargin < 2)
	maxTableSize = 4096;
	restartTable = 0;
end
if (nargin < 3)
	restartTable = 0;
end

	function code = findCode(lastCode, c)
		if (isempty(lastCode))
			code = c+1;
			return;
		else
			ii = table.codes(lastCode).prefix;
			jj = find([table.codes(ii).c] == c);
			code = ii(jj);
			return;
		end
		code = [];
		return;
	end

	function [] = addCode(lastCode, c)

		e.c = c;
		e.lastCode = lastCode;
		e.prefix = [];
		e.codeLength = table.codes(lastCode).codeLength + 1;
		table.codes(table.nextCode) = e;
		table.codes(lastCode).prefix = [table.codes(lastCode).prefix table.nextCode];
		table.nextCode = table.nextCode + 1;
	end

	function [] = newTable
		e.c = 0;
		e.lastCode = -1;
		e.prefix = [];
		e.codeLength = 1;
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
			table.codes(table.nextCode) = e;
			table.nextCode = table.nextCode + 1;
		end
	end

e.c = 0;
e.lastCode = -1;
e.prefix = [];
e.codeLength = 1;

newTable;
output = vector;
outputIndex = 1;
lastCode = [];
tic;
for index=1:length(vector)

	code = findCode(lastCode, vector(index));
	if ~isempty(code)
		lastCode = code;
	else
		output(outputIndex) = lastCode;
		outputIndex = outputIndex+1;
		if (table.nextCode <= maxTableSize)
			addCode(lastCode, vector(index));
			if (restartTable && table.nextCode == maxTableSize+1)
				newTable;
			end
		end
		lastCode = findCode([], vector(index));
	end
end
output(outputIndex) = lastCode;
output((outputIndex+1):end) = [];
table.codes = table.codes(1:table.nextCode-1);

end
function [output,table] = lzw2norm (vector, maxTableSize, restartTable)
vector = vector(:)';

if (nargin < 2)
	maxTableSize = 4096;
	restartTable = 0;
end
if (nargin < 3)
	restartTable = 0;
end

	function code = findCode(lastCode, c)

		if (isempty(lastCode))
			code = c+1;
			return;
		else
			ii = table.codes(lastCode).prefix;
			jj = find([table.codes(ii).c] == c);
			code = ii(jj);
			return;
		end
	end

	function [] = addCode(lastCode, c)

		e.c = c;	% NB using variable in parent to avoid allocation cost
		e.lastCode = lastCode;
		e.prefix = [];
		e.codeLength = table.codes(lastCode).codeLength + 1;
		table.codes(table.nextCode) = e;
		table.codes(lastCode).prefix = [table.codes(lastCode).prefix table.nextCode];
		table.nextCode = table.nextCode + 1;

	end

	function str = getCode(code)

		l = table.codes(code).codeLength;
		str = zeros(1, l);
		for ii = l:-1:1
			str(ii) = table.codes(code).c;
			code = table.codes(code).lastCode;
		end
	end

	function [] = newTable
		e.c = 0;
		e.lastCode = -1;
		e.prefix = [];
		e.codeLength = 1;
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
			table.codes(table.nextCode) = e;
			table.nextCode = table.nextCode + 1;
		end
	end

e.c = 0;
e.lastCode = -1;
e.prefix = [];
e.codeLength = 1;
newTable;
output = zeros(1, 3*length(vector));
outputIndex = 1;
lastCode = vector(1);
output(outputIndex) = table.codes(vector(1)).c;
outputIndex = outputIndex + 1;
character = table.codes(vector(1)).c;
tic;
for vectorIndex=2:length(vector)

	element = vector(vectorIndex);
	if (element >= table.nextCode)
		str = [getCode(lastCode) character];
    else
		str = getCode(element);
	end
	output(outputIndex + (0:length(str)-1)) = str;
	outputIndex = outputIndex + length(str);
	if ((length(output)-outputIndex) < 1.5*(length(vector)-vectorIndex))
		output = [output, zeros(1, 3*(length(vector)-vectorIndex))];
	end
	if (length(str) < 1)
		keyboard;
	end
	character = str(1);
	if (table.nextCode <= maxTableSize)
		addCode(lastCode, character);
		if (restartTable && table.nextCode == maxTableSize+1)
			newTable;
		end

	end
	lastCode = element;
end

output = output(1:outputIndex-1);
table.codes = table.codes(1:table.nextCode-1);

end