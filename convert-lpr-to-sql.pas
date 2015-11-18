program ConvertLprToSql;


{$MODE OBJFPC}
{$H+}			// Large string support

uses
	SysUtils;

const
	FILENAME =			'testfile.lpr';

	
function PositionOfXthChar(checkString: string; checkChar: char; checkCount: integer): integer;
var
	lengthString: integer;
	x: integer;
	posCounter: integer;
	charCounter: integer;
begin
	posCounter := 0;
	charCounter := 0;
	lengthString := Length(checkString);
	for x := 1 to lengthString do
	begin
		if checkString[x] = checkChar then
		begin
			Inc(charCounter);
			if charCounter = checkCount then
				posCounter := x;
			
		end;
	end;
	PositionOfXthChar := posCounter;
end;


procedure ProcessSingleFile(path: string);
var
	f: TextFile;
	line: string;
	positionOfFifthSepertator: integer;
begin
	Assign(f, path);
	
	{I+}
	Reset(f);
	repeat
		ReadLn(f, line);
		
		positionOfFifthSepertator := PositionOfXthChar(line, '|', 5);
		WriteLn(LeftStr(line, positionOfFifthSepertator - 1));
		
		//WriteLn(line);
	until Eof(f);
	Close(f);
end;


begin
	//WriteLn(PositionOfXthChar('2015-11-17 23:58:00|Security|NS00DC011.prod.ns.nl|4625|16|S-1-0-0|-|-|0x0|S-1-0-0|SW025V478$|DEVSP01|0xc000006d|%%2313|0xc0000064|3|NtLmSsp |NTLM|SW025V478|-|-|0|0x0|-|10.158.66.14|56577', '|', 5));
	ProcessSingleFile(FILENAME);
end.