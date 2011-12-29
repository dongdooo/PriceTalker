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
// 何秒ごとに読み上げるか？
extern int    ReadIntervalSec = 5;
// 小数点以下だけを読み上げたい時は true にする
extern bool   PointOnlyMode   = false;
// 最小桁を読みたくないときに1 にする
extern int    OmitDigit       = 0;
// Ask を読み上げたい時は true にする。
extern bool   ReadAsk         = false;
// 前回と同じ価格の場合読まないようにする時は true にする
extern bool   SkipSamePrice   = true;
// MinPrice と MaxPrice の間にある時だけ読み上げる。
extern double MaxPrice        = 999;
extern double MinPrice        = 0;

// サンプル文が読まれる
extern bool VoiceTestMode     = false;

int init(){
  if(IsDllsAllowed()==false)
    {
     Alert("DLL imports is not allowed. "+WindowExpertName()+" cannot run.");
     return(-1);
    }
    
  if(VoiceTestMode){
   AquesTalkDa_PlaySync("サーバーに,つながり/ま\'した", 110);
   AquesTalkDa_PlaySync("せつぞくが,きれま\'した", 120);
   AquesTalkDa_PlaySync("トレードを,はじめ/ま\'す", 120);
   AquesTalkDa_PlaySync("りかく,しま\'した", 120);
   AquesTalkDa_PlaySync("そんぎり,しま\'した", 120);      
   AquesTalkDa_PlaySync("おつかれさま/で\'した", 120);
   AquesTalkDa_PlaySync("トレンドかくにん", 120);
   AquesTalkDa_PlaySync("ぶれいく/あ\'うと+はっせー", 120);
   AquesTalkDa_PlaySync("めーるをおくりま\'した", 120);   
   AquesTalkDa_PlaySync("<NUMK VAL=1.3445>", 100);   
   AquesTalkDa_PlaySync("<NUM  VAL=3445>", 100);
   AquesTalkDa_PlaySync("ぷらす/<NUMK VAL=16>", 100);
   AquesTalkDa_PlaySync("まいなす/<NUMK VAL=3>", 100);

   }
}
int deinit(){ 
     switch(UninitializeReason())
       {
        case REASON_CHARTCLOSE:
        case REASON_REMOVE:AquesTalkDa_PlaySync("おつかれさま/で\'した", 120);break;
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
   
   //範囲外の価格は読み上げない
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