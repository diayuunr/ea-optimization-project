//+------------------------------------------------------------------+
//| EA02 - Range Breakout Expert Advisor                             |
//| Strategy: Range High/Low Breakout                                |
//| Platform: MetaTrader 5                                           |
//+------------------------------------------------------------------+
#property strict

#include <Trade/Trade.mqh>

CTrade trade;

//========================= INPUT PARAMETERS =========================

//--- Range
input int    RangeBars            = 20;       // Number of bars for range
input int    BreakoutBufferPoints = 20;       // Breakout buffer (points)

//--- Risk Management
input double RiskPercent          = 1.0;      // Risk per trade (%)
input double FixedLot             = 0.10;     // Fixed lot if RiskPercent = 0

//--- Stop Loss / Take Profit
input int    StopLossPoints       = 500;      // Stop Loss (points)
input double RiskRewardRatio      = 2.0;      // Take Profit = SL x RR

//--- Trading
input bool   AllowBuy             = true;
input bool   AllowSell            = true;
input int    MaxSpreadPoints      = 30;       // Maximum spread
input int    StartHour             = 0;        // Trading start hour
input int    EndHour               = 23;       // Trading end hour

//--- EA identification
input ulong  MagicNumber          = 20260902;

//========================= GLOBAL VARIABLES =========================

datetime lastBarTime = 0;

//+------------------------------------------------------------------+
//| Expert initialization                                            |
//+------------------------------------------------------------------+
int OnInit()
{
   trade.SetExpertMagicNumber(MagicNumber);

   Print("EA02 Range Breakout initialized.");
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Check new bar                                                    |
//+------------------------------------------------------------------+
bool IsNewBar()
{
   datetime currentBarTime = iTime(_Symbol, _Period, 0);

   if(currentBarTime != lastBarTime)
   {
      lastBarTime = currentBarTime;
      return true;
   }

   return false;
}

//+------------------------------------------------------------------+
//| Check trading hours                                              |
//+------------------------------------------------------------------+
bool IsTradingTime()
{
   MqlDateTime timeStruct;
   TimeToStruct(TimeCurrent(), timeStruct);

   int hour = timeStruct.hour;

   if(StartHour <= EndHour)
   {
      if(hour >= StartHour && hour <= EndHour)
         return true;
   }
   else
   {
      // Overnight session
      if(hour >= StartHour || hour <= EndHour)
         return true;
   }

   return false;
}

//+------------------------------------------------------------------+
//| Check spread                                                     |
//+------------------------------------------------------------------+
bool IsSpreadOK()
{
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);

   double spreadPoints = (ask - bid) / _Point;

   return(spreadPoints <= MaxSpreadPoints);
}

//+------------------------------------------------------------------+
//| Calculate lot size based on risk                                 |
//+------------------------------------------------------------------+
double CalculateLotSize()
{
   if(RiskPercent <= 0)
      return FixedLot;

   double balance = AccountInfoDouble(ACCOUNT_BALANCE);

   double riskMoney = balance * RiskPercent / 100.0;

   double tickSize  = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);

   if(tickSize <= 0 || tickValue <= 0)
      return FixedLot;

   double lossPerLot =
      (StopLossPoints * _Point / tickSize) * tickValue;

   if(lossPerLot <= 0)
      return FixedLot;

   double lot = riskMoney / lossPerLot;

   //--- broker limits
   double minLot  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maxLot  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);

   lot = MathMax(lot, minLot);
   lot = MathMin(lot, maxLot);

   lot = MathFloor(lot / lotStep) * lotStep;

   return NormalizeDouble(lot, 2);
}

//+------------------------------------------------------------------+
//| Check whether EA already has a position                          |
//+------------------------------------------------------------------+
bool HasOpenPosition()
{
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);

      if(ticket == 0)
         continue;

      if(PositionGetString(POSITION_SYMBOL) == _Symbol &&
         PositionGetInteger(POSITION_MAGIC) == (long)MagicNumber)
      {
         return true;
      }
   }

   return false;
}

//+------------------------------------------------------------------+
//| Calculate range high                                             |
//+------------------------------------------------------------------+
double GetRangeHigh()
{
   double highest = -DBL_MAX;

   for(int i = 1; i <= RangeBars; i++)
   {
      double high = iHigh(_Symbol, _Period, i);

      if(high > highest)
         highest = high;
   }

   return highest;
}

//+------------------------------------------------------------------+
//| Calculate range low                                              |
//+------------------------------------------------------------------+
double GetRangeLow()
{
   double lowest = DBL_MAX;

   for(int i = 1; i <= RangeBars; i++)
   {
      double low = iLow(_Symbol, _Period, i);

      if(low < lowest)
         lowest = low;
   }

   return lowest;
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   //--- Only evaluate once per new candle
   if(!IsNewBar())
      return;

   //--- Trading time filter
   if(!IsTradingTime())
      return;

   //--- Spread filter
   if(!IsSpreadOK())
      return;

   //--- Only one EA position at a time
   if(HasOpenPosition())
      return;

   //--- Need enough bars
   if(Bars(_Symbol, _Period) < RangeBars + 5)
      return;

   //--- Range
   double rangeHigh = GetRangeHigh();
   double rangeLow  = GetRangeLow();

   //--- Current prices
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);

   //--- Breakout levels
   double buyLevel  = rangeHigh + BreakoutBufferPoints * _Point;
   double sellLevel = rangeLow  - BreakoutBufferPoints * _Point;

   //--- Lot size
   double lot = CalculateLotSize();

   //--- Stop Loss
   double slDistance = StopLossPoints * _Point;

   //--- Take Profit
   double tpDistance = slDistance * RiskRewardRatio;

   //================================================================
   // BUY BREAKOUT
   //================================================================

   if(AllowBuy && ask > buyLevel)
   {
      double sl = ask - slDistance;
      double tp = ask + tpDistance;

      sl = NormalizeDouble(sl, _Digits);
      tp = NormalizeDouble(tp, _Digits);

      trade.Buy(
         lot,
         _Symbol,
         ask,
         sl,
         tp,
         "EA02 Range Breakout BUY"
      );

      return;
   }

   //================================================================
   // SELL BREAKOUT
   //================================================================

   if(AllowSell && bid < sellLevel)
   {
      double sl = bid + slDistance;
      double tp = bid - tpDistance;

      sl = NormalizeDouble(sl, _Digits);
      tp = NormalizeDouble(tp, _Digits);

      trade.Sell(
         lot,
         _Symbol,
         bid,
         sl,
         tp,
         "EA02 Range Breakout SELL"
      );

      return;
   }
}
//+------------------------------------------------------------------+