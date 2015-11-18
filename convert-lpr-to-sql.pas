program ConvertLprToSql;


{$MODE OBJFPC}
{$H+}			// Large string support


uses
	DateUtils,
	SysUtils,
	USupportLibrary;

	
var
	uniqueCodeCounter: integer;
	uniqueCodeDateTime: TDateTime;
	x: integer;
	
	
function GetUniqueCode: string;
//
//	1234567890123456789012
//	20151118-193137-004993
//
var
	currentDateTime: TDateTime;
begin
	currentDateTime := Now();
	if DateTimeToStr(currentDateTime) = DateTimeToStr(uniqueCodeDateTime) then
		Inc(uniqueCodeCounter)
	else
	begin
		uniqueCodeCounter := 0;
		uniqueCodeDateTime := Now();
	end;
	
	//WriteLn(DateTimeToStr(uniqueCodeDateTime), ':', uniqueCodeCounter);
	//WriteLn(FormatDateTime('yyyymmdd-hhnnss', uniqueCodeDateTime), ':', uniqueCodeCounter);
	GetUniqueCode := FormatDateTime('yyyymmdd-hhnnss', currentDateTime) + '-' + NumberAlign(uniqueCodeCounter,6);
end;
	
	
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


procedure ProcessSingleFile(pathLpr: string);
var
	fileLpr: TextFile;
	fileSql: TextFile;
	line: string;
	positionOfFifthSepertator: integer;
	partFixed: string;
	partVariable: string;
	pathSql: string;
	partFixedStrings: TStringArray;
	query: string;
	lineCounter: integer;
begin
	
	pathSql := pathLpr + '.sql';
	
	if FileExists(pathSql) then
		DeleteFile(pathSql);
	
	WriteLn('Converting ', pathLpr, ' to ', pathSql, ', please wait...');
	
	Assign(fileSql, pathSql);
	ReWrite(fileSql);
	
	Assign(fileLpr, pathLpr);
	{I+}
	Reset(fileLpr);
	
	lineCounter := 0;
	repeat
		ReadLn(fileLpr, line);
		Inc(lineCounter);
		if lineCounter > 1 then
		begin
			positionOfFifthSepertator := PositionOfXthChar(line, '|', 5);
			partFixed := LeftStr(line, positionOfFifthSepertator - 1);
			partVariable := RightStr(line, Length(line) - positionOfFifthSepertator);
			partFixedStrings := SplitString(partFixed, '|');
		
			query := 'INSERT INTO lprs ';
			query := query + 'SET ';
			query := query + 'RecordId=' + EncloseSingleQuote(GetUniqueCode) + ',';
			query := query + 'TimeGenerated=' + EncloseSingleQuote(partFixedStrings[0]) + ',';
			query := query + 'EventLog=' + EncloseSingleQuote(partFixedStrings[1]) + ',';
			query := query + 'ComputerName=' + EncloseSingleQuote(partFixedStrings[2]) + ',';
			query := query + 'EventID=' + partFixedStrings[3] + ',';
			query := query + 'EventType=' + partFixedStrings[4] + ',';
			query := query + 'Strings=' + EncloseSingleQuote(partVariable) + ';';
		
			WriteLn(fileSql, query);
		end;
	until Eof(fileLpr);
	Close(fileLpr);
	Close(fileSql);
	WriteLn('Converted ', lineCounter, ' lines.');
end;


begin
	uniqueCodeCounter := 0;
	uniqueCodeDateTime := Now();

	//for x := 1 to 5000 do
	//	WriteLn(GetUniqueCode());
	
	if ParamCount = 1 then
		ProcessSingleFile(ParamStr(1))
	else
		WriteLn('Usage: ', ParamStr(0), ' <lprfile>');
end.