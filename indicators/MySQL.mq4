#property copyright "copyright Yanoshin"
#property link "http://yanoshin.jp"

// indicator setting
#property indicator_chart_window

// MySQL setting
#import "libmysql.dll"
int mysql_init(int db);
int mysql_errno(int TMYSQL);
int mysql_real_connect( int TMYSQL,string host,string user,string password,
	string DB,int port,int socket,int clientflag);
int mysql_real_query(int TMSQL,string query,int length);
void mysql_close(int TMSQL);
int mysql;

extern string host = "host.of.mysql.db";
extern string user = "_username_";
extern string password = "_password_";
extern string DB = "_dbname_";
extern int port = 3306;

// SQL Log file setting
int handle;

// variables setting
datetime now_dt;
string now_str;
string symbol;
string table_name;
string chkDate;
string chkDate2;

// Initiation
int init()
{
	symbol = Symbol();

	// make SQL Logfile at first
	// SQL logfile is supporsed to be used as a backup
	chkDate = TimeDay(now_dt);
	handle = makeNewFile();

	// MySQL setup
	mysql = mysql_init(mysql);
	if (mysql != 0) Print("MySQL allocated");

   int clientflag = 0;
	string socket = "";
	int res = mysql_real_connect(mysql, host, user, password,
		DB, port, socket, clientflag);
	int err = GetLastError();
	if (res == mysql)
		Print("MySQL connected");
	else
	{
		Print("error = ", mysql, " ", mysql_errno(mysql), " ");
		return(1);
	}

	// Check the existance of DB table.
	// if not, build a table named with Symbol()
	table_name = "Ticks_" + symbol;
	string query = "";
	query = query + "CREATE TABLE IF NOT EXISTS " + table_name + " (";
	query = query + "id bigint unsigned NOT NULL auto_increment,";
	query = query + "symbol varchar(10) NOT NULL,";
	query = query + "datetime datetime NOT NULL,";
	query = query + "utime int unsigned NOT NULL,";
	query = query + "close float NOT NULL,";
	query = query + "ask float NOT NULL,";
	query = query + "bid float NOT NULL,";
	query = query + "volume_in_M1 int unsigned NOT NULL,";
	query = query + "broker char(50) NOT NULL,";
	query = query + "src_terminal varchar(50) NOT NULL,";
	query = query + "PRIMARY KEY (id)";
	query = query + ") ENGINE = MyISAM DEFAULT CHARSET = utf8;";
	int length = 0;
	length = StringLen(query);
	mysql_real_query(mysql, query, length);
	int myerr = mysql_errno(mysql);
	if (myerr > 0) Print("error = ", myerr);

	return(0);
}

// Main procedure
int start()
{
	// LogFile chake
	chkDate2 = TimeDay(now_dt);
	if(chkDate != chkDate2)
	{
		//if datetime changed since privious, make a new logfile
		closeFile(handle);
		handle = makeNewFile();
		chkDate = chkDate2;
	}

	//get a datetime data.
	now_dt = TimeCurrent();
	now_str = TimeToStr(now_dt, TIME_DATE|TIME_SECONDS);

	int limit = Bars - IndicatorCounted();
	//Print("Sumbol=", symbol, "NOW = ",now_str ,"Datetime = ", now_dt, " Close[0]=",Close[0], " Bid=", Bid, " Ask=", Ask);//DEBUG

	if(limit == 1)
	{
		// - SQL query setup
		string query = "";
		query = query + "insert into " + table_name + " (";
		query = query + "symbol, datetime, utime, close, ask, bid, volume_in_M1, broker, src_terminal";
		query = query + ") values(";
		query = query + "\"" + Symbol() + "\",";
		query = query + "\"" + TimeToStr(CurTime(), TIME_DATE|TIME_SECONDS) + "\",";
		query = query + now_dt + ",";
		query = query + NormalizeDouble(Close[0],6) + ",";
		query = query + Ask + ",";
		query = query + Bid + ",";
		query = query + iVolume(Symbol(), PERIOD_M1, 0) + ",";
		query = query + "\"MetaTrader4\",";
		query = query + "\"VM-Win-Trade\"";
		query = query + ");";
		//Print(query);

		//output SQL backup into Logfile
		FileSeek(handle, 0, SEEK_END);
		FileWrite(handle, query);

		// - MySQL writing
		int length = 0;
		length = StringLen(query);
		mysql_real_query(mysql,query,length);
		int myerr = mysql_errno(mysql);
		if (myerr>0) Print("error=",myerr);
	}
	return (0);
}

int deinit()
{
	closeFile(handle);
}

int makeNewFile()
{
	now_dt = TimeCurrent();
	now_str = TimeToStr(now_dt, TIME_DATE|TIME_SECONDS);

	int handle;

	string dirpath = "MySQL_log\\" + "" + TimeYear(now_dt) + "-" +
						TimeMonth(now_dt) + "-" + TimeDay(now_dt);
	string filename = dirpath+ "\\" + symbol + "_Tick.sql";
	handle = FileOpen(filename, FILE_CSV | FILE_READ | FILE_WRITE, ',');

	string msg = "---Session opened[" + now_str + "] ---";
	FileSeek(handle, 0, SEEK_END);
	FileWrite(handle, msg);
	return(handle);
}

int closeFile(int handle)
{
	now_dt = TimeCurrent();
	now_str = TimeToStr(now_dt, TIME_DATE|TIME_SECONDS);
	string msg = "--- Session closed[" + now_str + "] ---";
	FileSeek(handle, 0, SEEK_END);
	FileWrite(handle, msg);
	FileClose(handle);
}