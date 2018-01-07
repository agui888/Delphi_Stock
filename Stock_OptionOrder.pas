unit Stock_OptionOrder;

interface

uses Windows, Messages, SysUtils, Variants, Classes, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, StrUtils;

procedure FutureOrder();
procedure TempShowInterestStock();
procedure GetOpenOrder();
function LastInventoryCheck(DateType: String): Integer;

implementation

uses ChungYi_Main, Quote_uSKQ, SQLFunc, Public_Variant, StringList_Fun, DMRecord,
     Quote, Strategy;

// ���f�U��
procedure FutureOrder();
var i,j,k : integer;
   Item, ListItem, ListItem1 : TListItem;
   iCode : integer;
   Symbol,Price : String;
   strMsg : array[0..1023] of AnsiChar;
   iSize : integer;
begin
   K:= 0;
 //  if fmChungYi.edtPrice.Text= '' then fmChungYi.edtPrice.Text:= 'M'; // ����P�w
   fmChungYi.edtPrice.Text:= FloatToStr(CloseP); // ����P�w

   for i := 0 to 0 do
   begin
       Item := fmChungYi.ListView1.Items.Item[i];

       for j := 0 to 0 do
       begin
           ListItem := fmChungYi.ListView3.Items.Add;

           ListItem.Caption := Item.SubItems[0]+Item.Caption;
           ListItem.SubItems.Add(TickTime);  //0
           ListItem.SubItems.Add( fmChungYi.cbbCommNO.Text);  //1
           ListItem.SubItems.Add( fmChungYi.rgBuySell.Items.Strings[ fmChungYi.rgBuySell.ItemIndex]);
           ListItem.SubItems.Add( fmChungYi.rgTradeType.Items.Strings[ fmChungYi.rgTradeType.ItemIndex]);
           ListItem.SubItems.Add( fmChungYi.edtPrice.Text);
           ListItem.SubItems.Add(IntToStr(TradeQty));
           ListItem.SubItems.Add( '');
           ListItem.SubItems.Add( '');

           Symbol := Trim( fmChungYi.cbbCommNO.Text);
           Price := Trim( fmChungYi.edtPrice.Text);

           strMsg := #0;
           iSize := 1023;

           if iCode <> 0 then
           begin
            ShowMessage('�L�kŪ���Y�ɮw�s, �Ь��Ҩ��');
            Exit;
           end;
           iCode := SendFutureOrder(PAnsiChar(AnsiString(FutureAccount)), PAnsiChar(AnsiString(Symbol)),
             fmChungYi.rgTradeType.ItemIndex, k, fmChungYi.rgBuySell.ItemIndex, PAnsiChar(AnsiString(Price)), TradeQty,
             strMsg, @iSize);

             if (iCode <> SK_SUCCESS) and (iCode <> 5)  then
             begin
              ListItem.SubItems.Strings[7] := '�e�U����, Code: ' + IntToStr( iCode)+ ' ' + strMsg;
              // �p�G�O�Ҫ�����, �۰ʥ���
              // if AnsiContainsStr(strMsg, '�O�Ҫ�����') then fmChungYi.btnBalance.Click;
              // �Ȯɵ{��, ���R��
              TempShowInterestStock();
             end else begin
              TriggerInternal:= True;

              ListItem.SubItems.Strings[6] := strMsg;
              // ���}��������ܮw�s timer
               GetOpenInterest(PAnsiChar(AnsiString(FutureAccount)));
              // fmChungYi.OpenInterestTimer.Enabled:= True;

              TempShowInterestStock();
             end;
       end;
   end;
   LastInventory:= False; // �@�U���, �Q��d�ܧP�w�k false
   // ��ܷ���l�q
   fmQuote.lbBalance.Caption:= '����l�q: ' + FloatToStr(GetBalance());
 //  Windows.Beep(440, 1000);
end;

procedure TempShowInterestStock();
var Titem, ListItem: Tlistitem;
    I: Integer;
begin
 OrderList.Add(fmChungYi.edtPrice.Text);
 fmChungYi.ListV_Interest.Clear;

  // �g�J����
  if fmChungYi.edtPrice.Text= '' then
   fmChungYi.ListView3.Items[fmChungYi.ListView3.Items.Count - 1].SubItems.Strings[4]:= FloatToStr(CloseP)
  else fmChungYi.ListView3.Items[fmChungYi.ListView3.Items.Count - 1].SubItems.Strings[4]:= fmChungYi.edtPrice.Text;

  Titem := fmChungYi.ListV_Interest.Items.add;
  Titem.Caption := fmChungYi.ListView3.Items[0].Caption;  // �b��
  Titem.SubItems.Add(fmChungYi.cbbCommNO.Text);  // �ӫ~
  Titem.SubItems.Add(NowBuySell);  // �R��O
  Titem.SubItems.Add(fmChungYi.edtQty.Text);  // �����ܳ���
  Titem.SubItems.Add(FloatToStR(CloseP));  // ��������

  // �g�J��Ʈw
  ListItem := fmChungYi.ListView3.Items.Item[fmChungYi.ListView3.Items.Count - 1];
  SQLFunc.InsertData(ListItem);
  TradeQty:= 0; // �k�s

  if NowBuySell = '' then // NowBuySell <> '' �ɪ��ܥثe�i����, �ثe��ƲM��, �_�h���~
   fmChungYi.ListV_Interest.Clear;
end;

procedure GetOpenOrder();  // �H��Ʈw�覡  ��������ܤ��e (���R��)
var Titem, ListItem: Tlistitem;
    LeftQty: Integer;
begin
  if(not fmChungYi.cbOrderTest.Checked) then
    abort;
{  // ���ˬd����w�s
  LeftQty:= LastInventoryCheck(ThisTradeDate);
  DataModule1.asqQU_Temp.Close;
  DataModule1.asqQU_Temp.SQL.Text:= 'select * from RecordMsg where TradeDate="' + ThisTradeDate + '"';
  DataModule1.asqQU_Temp.Open;
  DataModule1.asqQU_Temp.Last;
  if DataModule1.asqQU_Temp.FieldByName('BuySell').Text = '' then
  begin  // �Y�L����w�s, �A�ˬd�Q��w�s
   LeftQty:= LastInventoryCheck(LastDate);
   DataModule1.asqQU_Temp.Close;
   DataModule1.asqQU_Temp.SQL.Text:= 'select * from RecordMsg where TradeDate="' + LastDate + '"';
   DataModule1.asqQU_Temp.Open;
   DataModule1.asqQU_Temp.Last;
  end;   }

  fmChungYi.ListV_Interest.Clear;
  LeftQty:= LastInventoryCheck(ThisTradeDate); // �P����L��
  DataModule1.asqQU_Temp.Close;
  DataModule1.asqQU_Temp.SQL.Text:= 'select * from RecordMsg';
  DataModule1.asqQU_Temp.Open;
  DataModule1.asqQU_Temp.Last;

  if (LeftQty > 0) then
  begin
   Titem := fmChungYi.ListV_Interest.Items.add;
   Titem.Caption := fmChungYi.ListView1.Items[0].Caption;  // �b��
   Titem.SubItems.Add(fmChungYi.cbbCommNO.Text);  // �ӫ~
   Titem.SubItems.Add(DataModule1.asqQU_Temp.FieldByName('BuySell').Text);  // �R��O
   Titem.SubItems.Add(IntToStr(LeftQty));  // �����ܳ���
   Titem.SubItems.Add(DataModule1.asqQU_Temp.FieldByName('Price').Text);  // ��������

   NowBuySell:= DataModule1.asqQU_Temp.FieldByName('BuySell').Text;
  end;
end;

function LastInventoryCheck(DateType: String): Integer;
var LastBuyQty, LastSellQty: Integer;
begin
{  // �P�w�O�_���d�ܳ�
  LastBuyQty:= 0;
  LastSellQty:= 0;
  LastInventory:= False;
  DataModule1.asqQU_Temp.Close;
  DataModule1.asqQU_Temp.SQL.Text:= 'select Sum(Qty) as TotalQty from RecordMsg where BuySell="B"';
  DataModule1.asqQU_Temp.Open;
  if DataModule1.asqQU_Temp.FieldByName('TotalQty').Text <> '' then
   LastBuyQty:= DataModule1.asqQU_Temp.FieldByName('TotalQty').AsInteger;

  DataModule1.asqQU_Temp.Close;
  DataModule1.asqQU_Temp.SQL.Text:= 'select Sum(Qty) as TotalQty from RecordMsg where BuySell="S"';
  DataModule1.asqQU_Temp.Open;
  if DataModule1.asqQU_Temp.FieldByName('TotalQty').Text <> '' then
   LastSellQty:= DataModule1.asqQU_Temp.FieldByName('TotalQty').AsInteger;

  Result:= abs(LastSellQty - LastBuyQty);  }

  // ���Χ@�k
  if fmChungYi.ListV_Interest.Items.Count > 0 then LastInventory:= True;
end;

end.