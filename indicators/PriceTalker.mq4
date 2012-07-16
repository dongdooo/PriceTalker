//+------------------------------------------------------------------+
//|                                             PriceTalker_v1.4.mq4 |
//|                                         Copyright (c) 2010, fai. |
//|                                    http://d.hatena.ne.jp/fai_fx/ |
//|                                    v1.4  Special thanks to Seeya |
//|                             http://dayaftertrade.blog45.fc2.com/ |
//+------------------------------------------------------------------+
//
// 
#property copyright "Copyright (c) 2010, fai"
#property link      "http://d.hatena.ne.jp/fai_fx/"

#property indicator_chart_window
#import "AquesTalkDa.dll"
int AquesTalkDa_PlaySync(string msg, int iSpeed);
int AquesTalkDa_Create(); 
int AquesTalkDa_Play(int H_AQTKDA, string message, int ispeed=100, int ia=0, int ib=0, int ic=0); 
void AquesTalkDa_Release(int hMe); 
#import

int hWndAq; 

//---- input parameters
// ���b���Ƃɓǂݏグ�邩�H
extern int		ReadIntervalSec	= 5;
// �����_�ȉ�������ǂݏグ�������� true �ɂ���
extern bool		PointOnlyMode	= false;
// �ŏ�����ǂ݂����Ȃ��Ƃ���1 �ɂ���
extern int		OmitDigit		= 0;
// �ǂݏグ�錅��(������) 0 �̏ꍇ�͑S��
extern int		DigitNum		= 3;
// Ask ��ǂݏグ�������� true �ɂ���B
extern bool		ReadAsk			= false;
// �O��Ɠ������i�̏ꍇ�ǂ܂Ȃ��悤�ɂ��鎞�� true �ɂ���
extern bool		SkipSamePrice	= true;
// MinPrice �� MaxPrice �̊Ԃɂ��鎞�����ǂݏグ��B
extern double	MaxPrice		= 999;
extern double	MinPrice		= 0;
// �������[�h�ōĐ�����ꍇ true �ɂ���
extern bool		Synchronize		= false;

// �}�[�P�b�g�I�[�v��/�N���[�Y����(GMT)
extern string	tokyoOpenStr	= "20:00";
extern double	tokyoTerm		= 8;

extern string	londonOpenStr	= "18:00";
extern double	londonTerm		= 8.5;

extern string	newyorkOpenStr	= "00:30";
extern double	newyorkTerm		= 7.5;

extern int		beforeTime		= 5;
//extern int		TimeZone		= 9;

datetime tokyoOpenTime, tokyoCloseTime;
datetime londonOpenTime, londonCloseTime;
datetime newyorkOpenTime, newyorkCloseTime;

datetime startTime;

// �T���v�������ǂ܂��
extern bool VoiceTestMode		= false;

bool tokyoOpenPre	= false;
bool tokyoOpen		= false;
bool londonOpenPre	= false;
bool londonOpen		= false;
bool newyorkOpenPre	= false;
bool newyorkOpen	= false;

int init()
{
	if(IsDllsAllowed()==false)
	{
		Alert("DLL imports is not allowed. "+WindowExpertName()+" cannot run.");
		return(-1);
	}

	hWndAq = AquesTalkDa_Create();

	if(VoiceTestMode)
	{
		AquesTalkDa_PlaySync("�T�[�o�[��,�Ȃ���/��\'����", 110);
		AquesTalkDa_PlaySync("��������,�����\'����", 120);
		AquesTalkDa_PlaySync("�g���[�h��,�͂���/��\'��", 120);
		AquesTalkDa_PlaySync("�肩��,����\'����", 120);
		AquesTalkDa_PlaySync("���񂬂�,����\'����", 120);      
		AquesTalkDa_PlaySync("�����ꂳ��/��\'����", 120);
		AquesTalkDa_PlaySync("�g�����h�����ɂ�", 120);
		AquesTalkDa_PlaySync("�Ԃꂢ��/��\'����+�͂����[", 120);
		AquesTalkDa_PlaySync("�߁[����������\'����", 120);   
		AquesTalkDa_PlaySync("<NUMK VAL=1.3445>", 100);   
		AquesTalkDa_PlaySync("<NUM  VAL=3445>", 100);
		AquesTalkDa_PlaySync("�Ղ炷/<NUMK VAL=16>", 100);
		AquesTalkDa_PlaySync("�܂��Ȃ�/<NUMK VAL=3>", 100);
	}

	initMarket();
}

int deinit()
{ 
	switch(UninitializeReason())
	{
		case REASON_CHARTCLOSE:
		case REASON_REMOVE:
			AquesTalkDa_PlaySync("�����ꂳ��/��\'����", 120);
			break;
		case REASON_RECOMPILE:
		case REASON_CHARTCHANGE:
		case REASON_PARAMETERS:
		case REASON_ACCOUNT:
			break;
   }

	AquesTalkDa_Release(hWndAq);
}

int start()
{
	datetime nowTime  = TimeLocal();

	if (startTime != StrToTime("00:00"))
	{
		initMarket();
	}

	checkMarket();

	static int LastCallTime = 0;
	double price = Bid;
	if(ReadAsk) price = Ask;
	static double PrevPrice = 0;

	if(price > MaxPrice || price < MinPrice) return(0);
	if(OmitDigit > 0) price = Omitter(price);
	if(SkipSamePrice && NormalizeDouble(PrevPrice - price, 8) == 0) return(0);

	if(TimeCurrent() - LastCallTime > ReadIntervalSec)
	{
		if(Synchronize)
		{
			AquesTalkDa_PlaySync(MakeVoicePrice(price), 105); 
		}
		else
		{
			AquesTalkDa_Play(hWndAq, MakeVoicePrice(price), 105, 0, 0, 0); 
		}
		LastCallTime = TimeCurrent();
		PrevPrice = price;
	}
}

//+------------------------------------------------------------------+
string MakeVoicePrice(double price)
{
	double pre = MathFloor(price);
	string post = "";

	if(!PointOnlyMode)
	{
		post = DoubleToStr(price, Digits - OmitDigit);
		post = "<NUMK VAL=" + post + ">";
	}
	else
	{
		post = DoubleToStr((price - pre) * MathPow(10, Digits - OmitDigit), 0);
		if(DigitNum > 0)
		{
			post = StringSubstr(post, StringLen(post) - DigitNum);
		}

		post = "<NUM VAL=" + post + ">";
	}

	return(post);
}

double Omitter(double price)
{
	return(MathFloor(price * MathPow(10, Digits - OmitDigit)) * MathPow(0.1, Digits - OmitDigit));
}

int initMarket()
{
	datetime nowTime = TimeLocal() - 32400;
//	startTime = nowTime - (nowTime % (60 * 60 * 24));
	startTime = StrToTime("00:00");

	tokyoOpenTime	= StrToTime(Year() + "." + Month() + "." + Day());
	tokyoCloseTime	= tokyoOpenTime + tokyoTerm * 60 * 60;
	londonOpenTime	= StrToTime(Year() + "." + Month() + "." + Day()) + 25200;
	londonCloseTime	= londonOpenTime + londonTerm * 60 * 60;
	newyorkOpenTime	= StrToTime(Year() + "." + Month() + "." + Day()) + 48600;
	newyorkCloseTime= newyorkOpenTime + newyorkTerm * 60 * 60;

	if (nowTime > tokyoOpenTime && nowTime < tokyoCloseTime)
	{
		tokyoOpen = true;
	}
	if (nowTime > tokyoOpenTime - beforeTime * 60 && nowTime < tokyoCloseTime - beforeTime * 60)
	{
		tokyoOpenPre = true;
	}

	if (nowTime > londonOpenTime && nowTime < londonCloseTime)
	{
		londonOpen = true;
	}
	if (nowTime > londonOpenTime - beforeTime * 60 && nowTime < londonCloseTime - beforeTime * 60)
	{
		londonOpenPre = true;
	}

	if (nowTime > newyorkOpenTime && nowTime < newyorkCloseTime)
	{
		newyorkOpen = true;
	}
	if (nowTime > newyorkOpenTime - beforeTime * 60 && nowTime < newyorkCloseTime - beforeTime * 60)
	{
		newyorkOpenPre = true;
	}

	Print("startTime =", startTime);
	Print("tokyoOpenTime =", tokyoOpenTime);
	Print("londonOpenTime =", londonOpenTime);
	Print("newyorkOpenTime =", newyorkOpenTime);

	Print("nowTime =", nowTime);

	Print("tokyoOpenPre =", tokyoOpenPre);
	Print("tokyoOpen =", tokyoOpen);
	Print("londonOpenPre =", londonOpenPre);
	Print("londonOpen =", londonOpen);
	Print("newyorkOpenPre =", newyorkOpenPre);
	Print("newyorkOpen =", newyorkOpen);

	return(0);
}

int checkMarket()
{
	datetime nowTime = TimeLocal() - 32400;

// ����
	if (!tokyoOpenPre && nowTime < tokyoCloseTime - beforeTime * 60)
	{
		if (nowTime > tokyoOpenTime - beforeTime * 60)
		{
			AquesTalkDa_PlaySync("�܂��Ȃ�,�Ƃ����傤�����傤�����[�Ղ񂵂܂�", 120);
			tokyoOpenPre = true;
		}
	}
	if (!tokyoOpen && nowTime < tokyoCloseTime)
	{
		if (nowTime > tokyoOpenTime)
		{
			AquesTalkDa_PlaySync("�Ƃ����傤�����傤�����[�Ղ񂵂܂���", 120);
			tokyoOpen = true;
		}
	}

	if (tokyoOpenPre && nowTime > tokyoCloseTime - beforeTime * 60)
	{
		AquesTalkDa_PlaySync("�܂��Ȃ�,�Ƃ����傤�����傤������[�����܂�", 120);
		tokyoOpenPre = false;
	}
	if (tokyoOpen && nowTime > tokyoCloseTime)
	{
		AquesTalkDa_PlaySync("�Ƃ����傤�����傤������[�����܂���", 120);
		tokyoOpen = false;
	}

// �����h��
	if (!londonOpenPre && nowTime < londonCloseTime - beforeTime * 60)
	{
		if (nowTime > londonOpenTime - beforeTime * 60)
		{
			AquesTalkDa_PlaySync("�܂��Ȃ�,���ǂ񂵂��傤�����[�Ղ񂵂܂�", 120);
			londonOpenPre = true;
		}
	}
	if (!londonOpen && nowTime < londonCloseTime)
	{
		if (nowTime > londonOpenTime)
		{
			AquesTalkDa_PlaySync("���ǂ񂵂��傤�����[�Ղ񂵂܂���", 120);
			londonOpen = true;
		}
	}

	if (londonOpenPre && nowTime > londonCloseTime - beforeTime * 60)
	{
		AquesTalkDa_PlaySync("�܂��Ȃ�,���ǂ񂵂��傤������[�����܂�", 120);
		londonOpenPre = false;
	}
	if (londonOpen && nowTime > londonCloseTime)
	{
		AquesTalkDa_PlaySync("���ǂ񂵂��傤������[�����܂���", 120);
		londonOpen = false;
	}

// �j���[���[�N
	if (!newyorkOpenPre && nowTime < newyorkCloseTime - beforeTime * 60)
	{
		if (nowTime > newyorkOpenTime - beforeTime * 60)
		{
			AquesTalkDa_PlaySync("�܂��Ȃ�,�ɂ�[��[�������傤�����[�Ղ񂵂܂�", 120);
			newyorkOpenPre = true;
		}
	}
	if (!newyorkOpen && nowTime < newyorkCloseTime)
	{
		if (nowTime > newyorkOpenTime)
		{
			AquesTalkDa_PlaySync("�ɂ�[��[�������傤�����[�Ղ񂵂܂���", 120);
			newyorkOpen = true;
		}
	}

	if (newyorkOpenPre && nowTime > newyorkCloseTime - beforeTime * 60)
	{
		AquesTalkDa_PlaySync("�܂��Ȃ�,�ɂ�[��[�������傤������[�����܂�", 120);
		newyorkOpenPre = false;
	}
	if (newyorkOpen && nowTime > newyorkCloseTime)
	{
		AquesTalkDa_PlaySync("�ɂ�[��[�������傤������[�����܂���", 120);
		newyorkOpen = false;
	}

	Print("nowTime =", nowTime);

	Print("tokyoOpenPre =", tokyoOpenPre);
	Print("tokyoOpen =", tokyoOpen);
	Print("londonOpenPre =", londonOpenPre);
	Print("londonOpen =", londonOpen);
	Print("newyorkOpenPre =", newyorkOpenPre);
	Print("newyorkOpen =", newyorkOpen);
}