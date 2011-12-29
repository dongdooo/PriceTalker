//+------------------------------------------------------------------+
//|                                             PriceTalker_v1.3.mq4 |
//|                                         Copyright (c) 2009, fai. |
//|                                    http://d.hatena.ne.jp/fai_fx/ |
//+------------------------------------------------------------------+
//
// 
#property copyright "Copyright (c) 2009, fai"
#property link      "http://d.hatena.ne.jp/fai_fx/"

#property indicator_chart_window
#import "AquesTalkDa.dll"
int AquesTalkDa_PlaySync(string msg, int iSpeed);
#import

//---- input parameters
// ���b���Ƃɓǂݏグ�邩�H
extern int    ReadIntervalSec = 5;
// �����_�ȉ�������ǂݏグ�������� true �ɂ���
extern bool   PointOnlyMode   = false;
// �ŏ�����ǂ݂����Ȃ��Ƃ���1 �ɂ���
extern int    OmitDigit       = 0;
// Ask ��ǂݏグ�������� true �ɂ���B
extern bool   ReadAsk         = false;
// �O��Ɠ������i�̏ꍇ�ǂ܂Ȃ��悤�ɂ��鎞�� true �ɂ���
extern bool   SkipSamePrice   = true;
// MinPrice �� MaxPrice �̊Ԃɂ��鎞�����ǂݏグ��B
extern double MaxPrice        = 999;
extern double MinPrice        = 0;

// �T���v�������ǂ܂��
extern bool VoiceTestMode     = false;

int init(){
  if(IsDllsAllowed()==false)
    {
     Alert("DLL imports is not allowed. "+WindowExpertName()+" cannot run.");
     return(-1);
    }
    
  if(VoiceTestMode){
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
}
int deinit(){ 
     switch(UninitializeReason())
       {
        case REASON_CHARTCLOSE:
        case REASON_REMOVE:AquesTalkDa_PlaySync("�����ꂳ��/��\'����", 120);break;
        case REASON_RECOMPILE:
        case REASON_CHARTCHANGE:
        case REASON_PARAMETERS:
        case REASON_ACCOUNT:break;
       }
}

int start()
  {
   static int LastCallTime = 0;
   double price = Bid;
   if(ReadAsk) price = Ask;
   static double PrevPrice = 0;
   
   //�͈͊O�̉��i�͓ǂݏグ�Ȃ�
   if(price > MaxPrice || price < MinPrice) return(0);
   if(OmitDigit > 0) price = Omitter(price);
   if(SkipSamePrice && NormalizeDouble(PrevPrice-price,8)==0 ) return(0);
   
   if(TimeCurrent() - LastCallTime > ReadIntervalSec ){
      AquesTalkDa_PlaySync(MakeVoicePrice(price), 105); 
      LastCallTime = TimeCurrent();
      PrevPrice = price;
   }
   return(0);
  }
//+------------------------------------------------------------------+
string MakeVoicePrice(double price){
   double pre = MathFloor(price);
   double val = (price-pre)*MathPow(10,Digits-OmitDigit);
   string post = "";

   if(!PointOnlyMode){
      post = "<NUMK VAL="+DoubleToStr(price,Digits-OmitDigit)+">";
   }else{
      post = "<NUM VAL="+DoubleToStr(val,0)+">";   
   }
   return(post);
}
double Omitter(double price)
{
   return( MathFloor(price*MathPow(10,Digits-OmitDigit))*MathPow(0.1,Digits-OmitDigit) );
}