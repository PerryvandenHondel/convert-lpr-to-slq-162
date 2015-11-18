program ConvertLprToSql;


{$MODE OBJFPC}
{$H+}			// Large string support

uses
	SysUtils,
	USupportLibrary;

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
	fileSql: TextFile;
	line: string;
	positionOfFifthSepertator: integer;
	partFixed: string;
	partVariable: string;
	pathSql: string;
	partFixedStrings: TStringArray;
	query: string;
begin
	
	pathSql := path + '.sql';
	
	if FileExists(pathSql) then
		DeleteFile(pathSql);
	
	Assign(fileSql, pathSql);
	ReWrite(fileSql);
	
	Assign(f, path);
	{I+}
	Reset(f);
	repeat
		ReadLn(f, line);
		
		positionOfFifthSepertator := PositionOfXthChar(line, '|', 5);
		partFixed := LeftStr(line, positionOfFifthSepertator - 1);
		partVariable := RightStr(line, Length(line) - positionOfFifthSepertator);
		
		//WriteLn(partFixed);
		//WriteLn(partVariable);
		//WriteLn;
		
		partFixedStrings := SplitString(partFixed, '|');
		
		query := 'INSERT INTO lprs ';
		query := query + 'SET ';
		query := query + 'TimeGenerated=' + EncloseSingleQuote(partFixedStrings[0]) + ',';
		query := query + 'EventLog=' + EncloseSingleQuote(partFixedStrings[1]) + ',';
		query := query + 'ComputerName=' + EncloseSingleQuote(partFixedStrings[2]) + ',';
		query := query + 'EventID=' + partFixedStrings[3] + ',';
		query := query + 'EventType=' + partFixedStrings[4] + ',';
		query := query + 'Strings=' + EncloseSingleQuote(partVariable) + ';';
		
		WriteLn(fileSql, query);
		
		
		//WriteLn(line);
	until Eof(f);
	Close(f);
	
	Close(fileSql);
end;


begin
	//WriteLn(PositionOfXthChar('2015-11-17 23:58:00|Security|NS00DC011.prod.ns.nl|4625|16|S-1-0-0|-|-|0x0|S-1-0-0|SW025V478$|DEVSP01|0xc000006d|%%2313|0xc0000064|3|NtLmSsp |NTLM|SW025V478|-|-|0|0x0|-|10.158.66.14|56577', '|', 5));
	ProcessSingleFile(FILENAME);
end.