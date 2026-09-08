//+------------------------------------------------------------------+
//| EA03 - RSI Mean Reversion                                        |
//| Reference: MQL5 Tutorial - Simple RSI Standalone Expert Advisor |
//| Platform: MetaTrader 5                                          |
//+------------------------------------------------------------------+
#property strict

#include <Trade/Trade.mqh>

CTrade trade;

//========================= INPUT PARAMETERS =========================

//--- RSI
input int      RSIPeriod            = 14;
input double   OverboughtLevel      = 70.0;
input double   OversoldLevel        = 30.0;

//--- Risk Management
input double   RiskPercent          = 0.0;
input double   FixedLot             = 0.10;

//--- Stop Loss / Take Profit
input int      StopLossPoints       = 300;
input double   RiskRewardRatio      = 2.0;

//--- Trading Filters
input int      MaxSpreadPoints      = 30;
input int      StartHour             = 0;
input int      EndHour               = 23;

//--- Trade direction
input bool     AllowBuy             = true;
input bool     AllowSell            = true;

//--- EA identification
input ulong    MagicNumber          = 20260903;

//========================= GLOBAL VARIABLES =========================

int      rsiHandle;
datetime lastBarTime = 0;

//+------------------------------------------------------------------+
//| Expert initialization                                            |
//+------------------------------------------------------------------+
int OnInit()
{
   //--- Create RSI indicator handle
   rsiHandle = iRSI(
      _Symbol,
      _Period,
      RSIPeriod,
      PRICE_CLOSE
   );

   if(rsiHandle == INVALID_HANDLE)
   {
      Print("Failed to create RSI handle.");
      return(INIT_FAILED);
   }

   trade.SetExpertMagicNumber(MagicNumber);

   Print("EA03 RSI Mean Reversion initialized.");

   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization                                          |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   if(rsiHandle != INVALID_HANDLE)
      IndicatorRelease(rsiHandle);
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
      return(hour >= StartHour && hour <= EndHour);
   }
   else
   {
      return(hour >= StartHour || hour <= EndHour);
   }
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
//| Check existing EA position                                      |
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
//| Calculate lot size                                               |
//+------------------------------------------------------------------+
double CalculateLotSize()
{
   if(RiskPercent <= 0.0)
      return FixedLot;

   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   double riskMoney = balance * RiskPercent / 100.0;

   double tickSize =
      SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);

   double tickValue =
      SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);

   if(tickSize <= 0 || tickValue <= 0)
      return FixedLot;

   double lossPerLot =
      (StopLossPoints * _Point / tickSize) * tickValue;

   if(lossPerLot <= 0)
      return FixedLot;

   double lot = riskMoney / lossPerLot;

   double minLot =
      SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);

   double maxLot =
      SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);

   double lotStep =
      SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);

   lot = MathMax(lot, minLot);
   lot = MathMin(lot, maxLot);

   lot = MathFloor(lot / lotStep) * lotStep;

   return NormalizeDouble(lot, 2);
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   //--- Only evaluate once per candle
   if(!IsNewBar())
      return;

   //--- Trading filters
   if(!IsTradingTime())
      return;

   if(!IsSpreadOK())
      return;

   //--- Only one position at a time
   if(HasOpenPosition())
      return;

   //--- Make sure enough data exists
   if(Bars(_Symbol, _Period) < RSIPeriod + 10)
      return;

   //--- RSI array
   double rsiValues[];

   ArraySetAsSeries(rsiValues, true);

   //--- Get RSI values
   if(CopyBuffer(
      rsiHandle,
      0,
      0,
      2,
      rsiValues
   ) < 2)
   {
      Print("Failed to copy RSI data.");
      return;
   }

   //--- Use the last CLOSED candle
   double rsiValue = rsiValues[1];

   //--- Current prices
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);

   //--- Lot size
   double lot = CalculateLotSize();

   //--- Stop Loss / Take Profit distance
   double slDistance = StopLossPoints * _Point;
   double tpDistance = slDistance * RiskRewardRatio;

   //================================================================
   // BUY
   // RSI below oversold level
   //================================================================

   if(AllowBuy && rsiValue < OversoldLevel)
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
         "EA03 RSI BUY"
      );

      return;
   }

   //================================================================
   // SELL
   // RSI above overbought level
   //================================================================

   if(AllowSell && rsiValue > OverboughtLevel)
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
         "EA03 RSI SELL"
      );

      return;
   }
}
//+------------------------------------------------------------------+