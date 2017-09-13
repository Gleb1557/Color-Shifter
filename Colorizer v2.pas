{$Copyright 'Брыкин Глеб'}
{$Company 'ЦКО и ДО Зеленоград'}
{$Product 'ImageColorizer'}
{$Version 'v11.04.2017'}
{$Reference 'System.Windows.Forms.dll'}
{$Reference 'System.Drawing.dll'}
{$Reference 'System.dll'}
{$Resource '1.jpg'}
{$Resource '2.jpg'}
{$Resource '3.jpg'}
{$Resource '4.jpg'}
{$Resource '5.jpg'}
{$AppType Windows}
Uses System;
Uses System.Windows.Forms;
Uses System.Drawing;
Uses System.Drawing.Imaging;
var
  MainForm: System.Windows.Forms.Form;

var
  MainToolStrip: System.Windows.Forms.ToolStrip;

var
  Colorizer: System.Windows.Forms.ToolStripMenuItem;

var
  ColorExamplesMenuItem: System.Windows.Forms.ToolStripMenuItem;

var
  BWMenuItem: System.Windows.Forms.ToolStripMenuItem;

var
  Save: System.Windows.Forms.ToolStripMenuItem;

var
  BWLabel: System.Windows.Forms.Label;

var
  BWImage: System.Windows.Forms.PictureBox;

var
  RGB1Label: System.Windows.Forms.Label;

var
  RGB1Image: System.Windows.Forms.PictureBox;

var
  RGB2Label: System.Windows.Forms.Label;

var
  RGB2Image: System.Windows.Forms.PictureBox;

var
  UseRGB2: System.Windows.Forms.CheckBox;

var
  Progress: System.Windows.Forms.ProgressBar;

var
  ProgressTimer: integer;

var
  ProgressMax: integer;

var
  Result: System.Drawing.Bitmap;

var
  WasConverted: Boolean;

procedure RGB_To_LAB(Red, Green, Blue: Integer; var L, A, B: Integer);
begin
  var Temp_R: real;
  var Temp_G: real;
  var Temp_B: real;
  Temp_R := Red / 255;
  Temp_G := Green / 255;
  Temp_B := Blue / 255;
  // Red
  if Temp_R > 0.04045
    Then Temp_R := Power(((Temp_R + 0.055) / 1.055), 2.4)
  Else Temp_R := Temp_R / 12.92;
  // Green
  if Temp_G > 0.04045
    Then Temp_G := Power(((Temp_G + 0.055) / 1.055), 2.4)
  Else Temp_G := Temp_G / 12.92;
  // Blue
  if Temp_B > 0.04045
    Then Temp_B := Power(((Temp_B + 0.055) / 1.055), 2.4)
  Else Temp_B := Temp_B / 12.92;
  Temp_R := Temp_R * 100;
  Temp_G := Temp_G * 100;
  Temp_B := Temp_B * 100;
  //Observer. = 2°, Illuminant = D65
  var X: real;
  var Y: real;
  var Z: real;
  X := Temp_R * 0.4124 + Temp_G * 0.3576 + Temp_B * 0.1805;
  Y := Temp_R * 0.2126 + Temp_G * 0.7152 + Temp_B * 0.0722;
  Z := Temp_R * 0.0193 + Temp_G * 0.1192 + Temp_B * 0.9505;
  var Temp_X: real;
  var Temp_Y: real;
  var Temp_Z: real;
  Temp_X := X / 95.047;
  Temp_Y := Y / 100;
  Temp_Z := Z / 108.883;
  // X
  if Temp_X > 0.008856
    Then Temp_X := Power(Temp_X, (1 / 3))
  Else Temp_X := 7.787 * Temp_X + 16 / 116;
  // Y
  if Temp_Y > 0.008856
    Then Temp_Y := Power(Temp_Y, (1 / 3))
  Else Temp_Y := 7.787 * Temp_Y + 16 / 116;
  // Z
  if Temp_Z > 0.008856
    Then Temp_Z := Power(Temp_Z, (1 / 3))
  Else Temp_Z := 7.787 * Temp_Z + 16 / 116;
  L := Round(Int(116 * Temp_Y - 16));
  A := Round(Int(500 * (Temp_X - Temp_Y)));
  B := Round(Int(200 * (Temp_Y - Temp_Z)));
end;

procedure LAB_To_RGB(L, A, B: Integer; var Red, Green, Blue: Integer);
begin
  var Temp_X: real;
  var Temp_Y: real;
  var Temp_Z: real;
  Temp_Y := (L + 16) / 116;
  Temp_X := A / 500 + Temp_Y;
  Temp_Z := Temp_Y - B / 200;
  // X
  if Power(Temp_X, 3) > 0.008856
    Then Temp_X := Power(Temp_X, 3)
  Else Temp_X := (Temp_X - 16 / 116) / 7.787;
  // Y
  if Power(Temp_Y, 3) > 0.008856
    Then Temp_Y := Power(Temp_Y, 3)
  Else Temp_Y := (Temp_Y - 16 / 116) / 7.787;
  // Z
  if Power(Temp_Z, 3) > 0.008856
    Then Temp_Z := Power(Temp_Z, 3)
  Else Temp_Z := (Temp_Z - 16 / 116) / 7.787;
  var X: real;
  var Y: real;
  var Z: real;
  X := 95.047 * Temp_X;
  Y := 100 * Temp_Y;
  Z := 108.883 * Temp_Z;
  Temp_X := X / 100;
  Temp_Y := Y / 100;
  Temp_Z := Z / 100;
  var Temp_R: real;
  var Temp_G: real;
  var Temp_B: real;
  Temp_R := Temp_X * 3.2406 + Temp_Y * (-1.5372) + Temp_Z * (-0.4986);
  Temp_G := Temp_X * (-0.9689) + Temp_Y * 1.8758 + Temp_Z * 0.0415;
  Temp_B := Temp_X * 0.0557 + Temp_Y * (-0.2040) + Temp_Z * 1.0570;
  // R
  if Temp_R > 0.0031308
    Then Temp_R := 1.055 * Power(Temp_R, (1 / 2.4)) - 0.055
  Else Temp_R := 12.92 * Temp_R;
  // G
  if Temp_G > 0.0031308
    Then Temp_G := 1.055 * Power(Temp_G, (1 / 2.4)) - 0.055
  Else Temp_G := 12.92 * Temp_G;
  // B
  if Temp_B > 0.0031308
    Then Temp_B := 1.055 * Power(Temp_B, (1 / 2.4)) - 0.055
  Else Temp_B := 12.92 * Temp_B;
  Red := Round(Int(Temp_R * 255));
  Green := Round(Int(Temp_G * 255));
  Blue := Round(Int(Temp_B * 255));
end;

type
  LABColor = Record
    L: integer;
    A: integer;
    B: integer;
  End;

type
  LABPicture = Class
  private 
    RGB: System.Drawing.Bitmap;
    LAB: array of array of LABColor;
  public 
    constructor Create(BMP: System.Drawing.Bitmap);
    begin
      RGB := new System.Drawing.Bitmap(BMP);
      SetLength(LAB, BMP.Height);
      for Var y := 0 to BMP.Height - 1 do
        SetLength(LAB[y], BMP.Width);
      for Var y := 0 to BMP.Height - 1 do
      begin
        for Var x := 0 to BMP.Width - 1 do
        begin
          ProgressTimer := ProgressTimer + 1;
          if Round(int(ProgressTimer / ProgressMax * 100)) <= 100
            Then Progress.Value := Round(int(ProgressTimer / ProgressMax * 100));
          RGB_To_LAB(BMP.GetPixel(x, y).R, BMP.GetPixel(x, y).G, BMP.GetPixel(x, y).B, LAB[y][x].L, LAB[y][x].A, LAB[y][x].B);
        end;
      end;
    end;
    
    property Bitmap: System.Drawing.Bitmap read RGB;
    procedure SetPixel(x, y: integer; c: LABColor);
    begin
      LAB[y][x] := C;
    end;
    
    function GetPixel(x, y: integer): LABColor;
    begin
      GetPixel := LAB[y][x];
    end;
    
    function ToRGB: System.Drawing.Bitmap;
    begin
      var Temp: System.Drawing.Bitmap;
      var R: integer;
      var G: integer;
      var B: integer;
      Temp := new System.Drawing.Bitmap(LAB[0].Length, LAB.Length);
      for Var y := 0 to LAB.Length - 1 do
      begin
        for Var x := 0 to LAB[0].Length - 1 do
        begin
          ProgressTimer := ProgressTimer + 1;
          if Round(int(ProgressTimer / ProgressMax * 100)) <= 100
            Then Progress.Value := Round(int(ProgressTimer / ProgressMax * 100));
          LAB_To_RGB(LAB[y][x].L, LAB[y][x].A, LAB[y][x].B, R, G, B);
          if R < 0
            Then R := 0;
          if R > 255
            Then R := 255;
          if G < 0
            Then G := 0;
          if G > 255
            Then G := 255;
          if B < 0
            Then B := 0;
          if B > 255
            Then B := 255;
          Temp.SetPixel(x, y, System.Drawing.Color.FromArgb(R, G, B));
        end;
      end;
      ToRGB := Temp;
    end;
  End;

type
  ColorExample = Record
    A: integer;
    B: integer;
    E: real;
    D: real;
  End;
  //
var
  BW_Temp: LABPicture;

type
  InitializingController = Record
    BW: Boolean;
    RGB1: Boolean;
    RGB2: Boolean;
  End;

var
  IsInitialized: InitializingController;

function ToRGB(Input_RGB: Bitmap; Input_BW: Bitmap): Bitmap;
begin
  var RGB: Bitmap;
  var BW: Bitmap;
  var RGB_LAB: LABPicture;
  var BW_LAB: LABPicture;
  var ColorExamples: array of ColorExample;
  RGB := new Bitmap(Input_RGB);
  BW := new Bitmap(Input_BW);
  if IsInitialized.RGB1 = False
  Then
  begin
    RGB_LAB := new LABPicture(RGB);
  end
  Else
  begin
    RGB_LAB := new LABPicture(RGB);
  end;
  if IsInitialized.BW = False
  Then
  begin
    BW_LAB := new LABPicture(BW);
    IsInitialized.BW := True;
    BW_Temp := BW_LAB;
  end
  Else
  begin
    BW_LAB := BW_Temp;
  end;
  var x: integer;
  var y: integer;
  var Random_X: integer;
  var Random_Y: integer;
  while (RGB.Width mod 15) <> 0 do
    RGB := new Bitmap(RGB, RGB.Width - 1, RGB.Height);
  while (RGB.Height mod 15) <> 0 do
    RGB := new Bitmap(RGB, RGB.Width, RGB.Height - 1);
  SetLength(ColorExamples, 225);
  var Temp1: real;
  var Temp2: real;
  var Temp3: integer;
  Temp3 := 0;
  while y < (RGB.Height - 1) do
  begin
    while x < (RGB.Width - 1) do
    begin
      ProgressTimer := ProgressTimer + 1;
      if Round(int(ProgressTimer / ProgressMax * 100)) <= 100
        Then Progress.Value := Round(int(ProgressTimer / ProgressMax * 100));
      Random_X := 0;
      Random_Y := 0;
      Temp1 := 0;
      Temp2 := 0;
      while not (((Random_X + 13) < (RGB.Width - 1)) and ((Random_X - 13) > 0)) do
        Random_X := PABCSystem.Random(x, x + 15);
      while not (((Random_Y + 13) < (RGB.Height - 1)) and ((Random_Y - 13) > 0)) do
        Random_Y := PABCSystem.Random(y, y + 15);
      for Var y1 := (Random_Y - 13) to (Random_Y + 12 - 1) do
      begin
        for Var x1 := (Random_X - 13) to (Random_X + 12 - 1) do
        begin
          Temp1 := Temp1 + RGB_LAB.GetPixel(x1, y1).L;
        end;
      end;
      Temp1 := Temp1 / 625;
      ColorExamples[Temp3].E := Temp1;
      for Var y1 := (Random_Y - 13) to (Random_Y + 12 - 1) do
      begin
        for Var x1 := (Random_X - 13) to (Random_X + 12 - 1) do
        begin
          Temp2 := Temp2 + sqr(RGB_LAB.GetPixel(x1, y1).L - Temp1);
        end;
      end;
      Temp2 := Temp2 / 625;
      Temp2 := sqrt(Temp2);
      ColorExamples[Temp3].D := Temp2;
      ColorExamples[Temp3].A := RGB_LAB.GetPixel(Random_X, Random_Y).A;
      ColorExamples[Temp3].B := RGB_LAB.GetPixel(Random_X, Random_Y).B;
      Temp3 := Temp3 + 1;
      x := x + (RGB.Width div 15);
    end;
    x := 0;
    y := y + (RGB.Height div 15);
  end;
  Temp1 := 0;
  Temp2 := 0;
  var Temp4: real;
  var Temp5: integer;
  for y := 0 to BW.Height - 1 do
  begin
    for x := 0 to BW.Width - 1 do
    begin
      ProgressTimer := ProgressTimer + 1;
      if Round(int(ProgressTimer / ProgressMax * 100)) <= 100
        Then Progress.Value := Round(int(ProgressTimer / ProgressMax * 100));
      Temp1 := 0;
      Temp2 := 0;
      if (y > 13) and (y < BW.Height - 12) and (x > 13) and (x < BW.Width - 12)
      Then
      begin
        for Var y1 := y - 13 to y + 12 - 1 do
        begin
          for Var x1 := x - 13 to x + 12 - 1 do
          begin
            Temp1 := Temp1 + BW_LAB.GetPixel(x1, y1).L;
          end;
        end;
        Temp1 := Temp1 / 625;
        for Var y1 := y - 13 to y + 12 - 1 do
        begin
          for Var x1 := x - 13 to x + 12 - 1 do
          begin
            Temp2 := Temp2 + sqr(BW_LAB.GetPixel(x1, y1).L - Temp1);
          end;
        end;
        Temp2 := Temp2 / 625;
        Temp2 := sqrt(Temp2);
      end;
      //
      if (y > 13) and (y < BW.Height - 12) and (x <= 13) and (x < BW.Width - 12)
      Then
      begin
        for Var y1 := y - 13 to y + 12 - 1 do
        begin
          for Var x1 := x to x + 25 - 1 do
          begin
            Temp1 := Temp1 + BW_LAB.GetPixel(x1, y1).L;
          end;
        end;
        Temp1 := Temp1 / 625;
        for Var y1 := y - 13 to y + 12 - 1 do
        begin
          for Var x1 := x to x + 25 - 1 do
          begin
            Temp2 := Temp2 + sqr(BW_LAB.GetPixel(x1, y1).L - Temp1);
          end;
        end;
        Temp2 := Temp2 / 625;
        Temp2 := sqrt(Temp2);
      end;
      //
      if (y <= 13) and (y < BW.Height - 12) and (x > 13) and (x < BW.Width - 12)
      Then
      begin
        for Var y1 := y to y + 25 - 1 do
        begin
          for Var x1 := x - 13 to x + 12 - 1 do
          begin
            Temp1 := Temp1 + BW_LAB.GetPixel(x1, y1).L;
          end;
        end;
        Temp1 := Temp1 / 625;
        for Var y1 := y to y + 25 - 1 do
        begin
          for Var x1 := x - 13 to x + 12 - 1 do
          begin
            Temp2 := Temp2 + sqr(BW_LAB.GetPixel(x1, y1).L - Temp1);
          end;
        end;
        Temp2 := Temp2 / 625;
        Temp2 := sqrt(Temp2);
      end;
      //
      if (y <= 13) and (y < BW.Height - 12) and (x <= 13) and (x < BW.Width - 12)
      Then
      begin
        for Var y1 := y to y + 25 - 1 do
        begin
          for Var x1 := x to x + 25 - 1 do
          begin
            Temp1 := Temp1 + BW_LAB.GetPixel(x1, y1).L;
          end;
        end;
        Temp1 := Temp1 / 625;
        for Var y1 := y to y + 25 - 1 do
        begin
          for Var x1 := x to x + 25 - 1 do
          begin
            Temp2 := Temp2 + sqr(BW_LAB.GetPixel(x1, y1).L - Temp1);
          end;
        end;
        Temp2 := Temp2 / 625;
        Temp2 := sqrt(Temp2);
      end;
      //
      if (y > 13) and (y >= BW.Height - 12) and (x > 13) and (x < BW.Width - 12)
      Then
      begin
        for Var y1 := y - 25 + 1 to y do
        begin
          for Var x1 := x - 13 to x + 12 - 1 do
          begin
            Temp1 := Temp1 + BW_LAB.GetPixel(x1, y1).L;
          end;
        end;
        Temp1 := Temp1 / 625;
        for Var y1 := y - 25 + 1 to y do
        begin
          for Var x1 := x - 13 to x + 12 - 1 do
          begin
            Temp2 := Temp2 + sqr(BW_LAB.GetPixel(x1, y1).L - Temp1);
          end;
        end;
        Temp2 := Temp2 / 625;
        Temp2 := sqrt(Temp2);
      end;
      //
      if (y > 13) and (y < BW.Height - 12) and (x > 13) and (x >= BW.Width - 12)
      Then
      begin
        for Var y1 := y - 13 to y + 12 - 1 do
        begin
          for Var x1 := x - 25 + 1 to x do
          begin
            Temp1 := Temp1 + BW_LAB.GetPixel(x1, y1).L;
          end;
        end;
        Temp1 := Temp1 / 625;
        for Var y1 := y - 13 to y + 12 - 1 do
        begin
          for Var x1 := x - 25 + 1 to x do
          begin
            Temp2 := Temp2 + sqr(BW_LAB.GetPixel(x1, y1).L - Temp1);
          end;
        end;
        Temp2 := Temp2 / 625;
        Temp2 := sqrt(Temp2);
      end;
      //
      if (y > 13) and (y >= BW.Height - 12) and (x > 13) and (x >= BW.Width - 12)
      Then
      begin
        for Var y1 := y - 25 + 1 to y do
        begin
          for Var x1 := x - 25 + 1 to x do
          begin
            Temp1 := Temp1 + BW_LAB.GetPixel(x1, y1).L;
          end;
        end;
        Temp1 := Temp1 / 625;
        for Var y1 := y - 25 + 1 to y do
        begin
          for Var x1 := x - 25 + 1 to x do
          begin
            Temp2 := Temp2 + sqr(BW_LAB.GetPixel(x1, y1).L - Temp1);
          end;
        end;
        Temp2 := Temp2 / 625;
        Temp2 := sqrt(Temp2);
      end;
      //
      if (y > 13) and (y >= BW.Height - 12) and (x <= 13) and (x < BW.Width - 12)
      Then
      begin
        for Var y1 := y - 25 + 1 to y do
        begin
          for Var x1 := x to x + 25 - 1 do
          begin
            Temp1 := Temp1 + BW_LAB.GetPixel(x1, y1).L;
          end;
        end;
        Temp1 := Temp1 / 625;
        for Var y1 := y - 25 + 1 to y do
        begin
          for Var x1 := x to x + 25 - 1 do
          begin
            Temp2 := Temp2 + sqr(BW_LAB.GetPixel(x1, y1).L - Temp1);
          end;
        end;
        Temp2 := Temp2 / 625;
        Temp2 := sqrt(Temp2);
      end;
      //
      if (y <= 13) and (y < BW.Height - 12) and (x > 13) and (x >= BW.Width - 12)
      Then
      begin
        for Var y1 := y to y + 25 - 1 do
        begin
          for Var x1 := x - 25 + 1 to x do
          begin
            Temp1 := Temp1 + BW_LAB.GetPixel(x1, y1).L;
          end;
        end;
        Temp1 := Temp1 / 625;
        for Var y1 := y to y + 25 - 1 do
        begin
          for Var x1 := x - 25 + 1 to x do
          begin
            Temp2 := Temp2 + sqr(BW_LAB.GetPixel(x1, y1).L - Temp1);
          end;
        end;
        Temp2 := Temp2 / 625;
        Temp2 := sqrt(Temp2);
      end;
      //
      Temp4 := abs(Temp1 - ColorExamples[0].E) + abs(Temp2 - ColorExamples[0].D);
      for Var Colorizator := 1 to 224 do
      begin
        if (abs(Temp1 - ColorExamples[Colorizator].E) + abs(Temp2 - ColorExamples[Colorizator].D)) < Temp4
        Then
        begin
          Temp5 := Colorizator;
          Temp4 := abs(Temp1 - ColorExamples[Colorizator].E) + abs(Temp2 - ColorExamples[Colorizator].D);
        end;
      end;
      var Temp: LABColor;
      Temp.L := BW_LAB.GetPixel(x, y).L;
      Temp.A := ColorExamples[Temp5].A;
      Temp.B := ColorExamples[Temp5].B;
      BW_LAB.SetPixel(x, y, Temp);
      Temp4 := 0;
      Temp5 := 0;
      //
    end;
  end;
  ToRGB := new Bitmap(BW_LAB.ToRGB);
end;

function Colorize_2(BW: Bitmap; RGB1: Bitmap; RGB2: Bitmap): Bitmap;
begin
  var
  RGB: Bitmap;
  
  var
  BW_Temp: Bitmap;
  
  var
  Temp1: Bitmap;
  
  var
  Temp2: Bitmap;
  BW_Temp := new Bitmap(BW);
  RGB := new Bitmap(RGB1, BW.Size);
  Temp1 := ToRGB(RGB, BW_Temp);
  RGB := new Bitmap(RGB2, BW.Size);
  Temp2 := ToRGB(RGB, BW_Temp);
  for Var y := 0 to Temp1.Height - 1 do
  begin
    for Var x := 0 to Temp1.Width - 1 do
    begin
      ProgressTimer := ProgressTimer + 1;
      if Round(int(ProgressTimer / ProgressMax * 100)) <= 100
        Then Progress.Value := Round(int(ProgressTimer / ProgressMax * 100));
      Temp2.SetPixel(x, y, Color.FromArgb(Round((Temp1.GetPixel(x, y).R + Temp2.GetPixel(x, y).R) / 2), Round((Temp1.GetPixel(x, y).G + Temp2.GetPixel(x, y).G) / 2), Round((Temp1.GetPixel(x, y).B + Temp2.GetPixel(x, y).B) / 2)));
    end;
  end;
  Colorize_2 := Temp2;
end;
  //
type
  InitializationControl = Record
    RGB1IsOpen: Boolean;
    RGB2IsUsing: Boolean;
    RGB2IsOpen: Boolean;
    BWIsOpen: Boolean
  End;

var
  Init: InitializationControl;

type
  BackgroundResources = Record
    BW: System.Drawing.Bitmap;
    RGB1: System.Drawing.Bitmap;
    RGB2: System.Drawing.Bitmap;
  End;

var
  __BackgroundResources: BackgroundResources;

type
  Resources = Record
    BW: System.Drawing.Bitmap;
    RGB1: System.Drawing.Bitmap;
    RGB2: System.Drawing.Bitmap;
  End;

var
  __Resources: Resources;

type
  Arguments = Array of Byte;

procedure VisualizeColorization(Args: Object);
begin
  var arr: array of Byte;
  arr := args as Arguments;
  if (arr[0] = 1) and (arr[1] = 1)
  Then
  begin
    IsInitialized.BW := False;
    ProgressTimer := 0;
    ProgressMax := 0;
    Sleep(10);
    ProgressMax := 225 + 225 + 6 * (Round(250 / __BackgroundResources.BW.Height * __BackgroundResources.BW.Width) * 250);
    var Result_1: System.Drawing.Bitmap;
    Sleep(10);
    Result_1 := Colorize_2(new System.Drawing.Bitmap(__BackgroundResources.BW, new System.Drawing.Size(Round(250 / __BackgroundResources.BW.Height * __BackgroundResources.BW.Width), 250)), new System.Drawing.Bitmap(__BackgroundResources.RGB1, new System.Drawing.Size(Round(250 / __BackgroundResources.RGB1.Height * __BackgroundResources.RGB1.Width), 250)), new System.Drawing.Bitmap(__BackgroundResources.RGB2, new System.Drawing.Size(Round(250 / __BackgroundResources.RGB2.Height * __BackgroundResources.RGB2.Width), 250)));
    BWImage.Image := new System.Drawing.Bitmap(Result_1, __BackgroundResources.BW.Size);
    IsInitialized.BW := False;
    Progress.Value := 0;
  end
  Else
  begin
    IsInitialized.BW := False;
    ProgressTimer := 0;
    ProgressMax := 0;
    ProgressMax := 225 + 225 + 3 * (Round(250 / __BackgroundResources.BW.Height * __BackgroundResources.BW.Width) * 250);
    var Result_1: System.Drawing.Bitmap;
    Result_1 := ToRGB(new System.Drawing.Bitmap(__BackgroundResources.RGB1, new System.Drawing.Size(Round(250 / __BackgroundResources.BW.Height * __BackgroundResources.BW.Width), 250)), new System.Drawing.Bitmap(__BackgroundResources.BW, new System.Drawing.Size(Round(250 / __BackgroundResources.BW.Height * __BackgroundResources.BW.Width), 250)));
    BWImage.Image := new System.Drawing.Bitmap(Result_1, __BackgroundResources.BW.Size);
    IsInitialized.BW := False;
    Progress.Value := 0;
  end;
end;

procedure ColorizeBW(sender: object);
begin
  if (Init.RGB2IsOpen = True) and (Init.RGB2IsUsing = True)
  Then
  begin
    Save.DropDownItems.Item[0].Enabled := False;
    MainForm.Text := 'Окрашивание изображений - Окрашивание';
    ProgressMax := 0;
    ProgressTimer := 0;
    if IsInitialized.BW = False
      Then ProgressMax := 225 + 225 + 4 * (__Resources.BW.Width * __Resources.BW.Height) + __Resources.RGB1.Width * __Resources.RGB1.Height + __Resources.RGB2.Width * __Resources.RGB2.Height
    Else ProgressMax := 225 + 225 + 3 * (__Resources.BW.Width * __Resources.BW.Height) + __Resources.RGB1.Width * __Resources.RGB1.Height + __Resources.RGB2.Width * __Resources.RGB2.Height;
    Result := new System.Drawing.Bitmap(Colorize_2(__Resources.BW, __Resources.RGB1, __Resources.RGB2));
  end
  Else
  begin
    ProgressMax := 0;
    ProgressTimer := 0;
    MainForm.Text := 'Окрашивание изображений - Окрашивание';
    if IsInitialized.BW = False
      Then ProgressMax := 225 + 3 * (__Resources.BW.Width * __Resources.BW.Height) + __Resources.RGB1.Width * __Resources.RGB1.Height
    Else ProgressMax := 225 + 2 * (__Resources.BW.Width * __Resources.BW.Height) + __Resources.RGB1.Width * __Resources.RGB1.Height;
    Result := new System.Drawing.Bitmap(ToRGB(new System.Drawing.Bitmap(__Resources.RGB1, __Resources.BW.Size), __Resources.BW));
  end;
  MainForm.Text := 'Окрашивание изображений';
  Progress.Value := 0;
  Save.DropDownItems.Item[0].Enabled := True;
  WasConverted := True;
end;

procedure Colorize(sender: object; E: System.EventArgs);
begin
  var ColorizationThread: System.Threading.Thread;
  ColorizationThread := new System.Threading.Thread(ColorizeBW);
  ColorizationThread.Start();
end;

procedure AddRGB1(sender: object; E: System.EventArgs);
begin
  var OpenRGB1Image: System.Windows.Forms.OpenFileDialog;
  OpenRGB1Image := new System.Windows.Forms.OpenFileDialog;
  OpenRGB1Image.Title := 'Открыть первое цветное изображение';
  OpenRGB1Image.Filter := 'Изображения(*.jpg; *.bmp; *.png)|*.jpg; *.bmp; *.png';
  if OpenRGB1Image.ShowDialog = System.Windows.Forms.DialogResult.OK
  Then
  begin
    ColorExamplesMenuItem.DropDownItems.Item[0].Image := new System.Drawing.Bitmap(GetResourceStream('1.jpg'));
    Init.RGB1IsOpen := True;
    __BackgroundResources.RGB1 := new System.Drawing.Bitmap(new System.Drawing.Bitmap(OpenRGB1Image.FileName), new System.Drawing.Size(290, Round(290 / (new System.Drawing.Bitmap(OpenRGB1Image.FileName)).Width * (new System.Drawing.Bitmap(OpenRGB1Image.FileName)).Height)));
    __Resources.RGB1 := new System.Drawing.Bitmap(OpenRGB1Image.FileName);
    RGB1Image.Image := __BackgroundResources.RGB1;
    if (Init.BWIsOpen = True) and (Init.RGB1IsOpen = True) and (((Init.RGB2IsUsing = True) and (Init.RGB2IsOpen = True)) or ((Init.RGB2IsUsing = False) and (Init.RGB2IsOpen = False)) or ((Init.RGB2IsUsing = False) and (Init.RGB2IsOpen = True)))
      Then
    begin
      Colorizer.DropDownItems.Item[0].Enabled := True;
      if (Init.BWIsOpen = True) and (Init.RGB1IsOpen = True) and (Init.RGB2IsUsing = False)
      Then
      begin
        var args: Arguments;
        SetLength(args, 2);
        args[0] := 1;
        args[1] := 0;
        var ColorizationThread: System.Threading.Thread;
        ColorizationThread := new System.Threading.Thread(VisualizeColorization);
        ColorizationThread.Start(args);
      end
      Else
      if (Init.BWIsOpen = True) and (Init.RGB1IsOpen = True) and (Init.RGB2IsOpen = True) and (Init.RGB2IsUsing = True)
      Then
      begin
        var args: Arguments;
        SetLength(args, 2);
        args[0] := 1;
        args[1] := 1;
        var ColorizationThread: System.Threading.Thread;
        ColorizationThread := new System.Threading.Thread(VisualizeColorization);
        ColorizationThread.Start(args);
      end;
    end;
  end;
end;

procedure AddRGB2(sender: object; E: System.EventArgs);
begin
  var OpenRGB2Image: System.Windows.Forms.OpenFileDialog;
  OpenRGB2Image := new System.Windows.Forms.OpenFileDialog;
  OpenRGB2Image.Title := 'Открыть второе цветное изображение';
  OpenRGB2Image.Filter := 'Изображения(*.jpg; *.bmp; *.png)|*.jpg; *.bmp; *.png';
  if OpenRGB2Image.ShowDialog = System.Windows.Forms.DialogResult.OK
  Then
  begin
    ColorExamplesMenuItem.DropDownItems.Item[1].Image := new System.Drawing.Bitmap(GetResourceStream('1.jpg'));
    Init.RGB2IsOpen := True;
    __BackgroundResources.RGB2 := new System.Drawing.Bitmap(new System.Drawing.Bitmap(OpenRGB2Image.FileName), new System.Drawing.Size(290, Round(290 / (new System.Drawing.Bitmap(OpenRGB2Image.FileName)).Width * (new System.Drawing.Bitmap(OpenRGB2Image.FileName)).Height)));
    __Resources.RGB2 := new System.Drawing.Bitmap(OpenRGB2Image.FileName);
    RGB2Image.Image := __BackgroundResources.RGB2;
    if (Init.BWIsOpen = True) and (Init.RGB1IsOpen = True) and (((Init.RGB2IsUsing = True) and (Init.RGB2IsOpen = True)) or ((Init.RGB2IsUsing = False) and (Init.RGB2IsOpen = False)) or ((Init.RGB2IsUsing = False) and (Init.RGB2IsOpen = True)))
      Then
    begin
      Colorizer.DropDownItems.Item[0].Enabled := True;
      if (Init.RGB2IsUsing = True) and (Init.RGB2IsOpen = True) and (Init.BWIsOpen = True) and (Init.RGB1IsOpen = True)
      Then
      begin
        var args: Arguments;
        SetLength(args, 2);
        args[0] := 1;
        args[1] := 1;
        var ColorizationThread: System.Threading.Thread;
        ColorizationThread := new System.Threading.Thread(VisualizeColorization);
        ColorizationThread.Start(args);
      end;
    end;
  end;
end;

procedure AddBW(sender: object; E: System.EventArgs);
begin
  var OpenBWImage: System.Windows.Forms.OpenFileDialog;
  OpenBWImage := new System.Windows.Forms.OpenFileDialog;
  OpenBWImage.Title := 'Открыть чёрно-белое изображение';
  OpenBWImage.Filter := 'Изображения(*.jpg; *.bmp; *.png)|*.jpg; *.bmp; *.png';
  if OpenBWImage.ShowDialog = System.Windows.Forms.DialogResult.OK
  Then
  begin
    BWMenuItem.DropDownItems.Item[0].Image := new System.Drawing.Bitmap(GetResourceStream('1.jpg'));
    IsInitialized.BW := False;
    Init.BWIsOpen := True;
    __BackgroundResources.BW := new System.Drawing.Bitmap(new System.Drawing.Bitmap(OpenBWImage.FileName), new System.Drawing.Size(290, Round(290 / (new System.Drawing.Bitmap(OpenBWImage.FileName)).Width * (new System.Drawing.Bitmap(OpenBWImage.FileName)).Height)));
    __Resources.BW := new System.Drawing.Bitmap(OpenBWImage.FileName);
    BWImage.Image := __BackgroundResources.BW;
    if (Init.BWIsOpen = True) and (Init.RGB1IsOpen = True) and (((Init.RGB2IsUsing = True) and (Init.RGB2IsOpen = True)) or ((Init.RGB2IsUsing = False) and (Init.RGB2IsOpen = False)) or ((Init.RGB2IsUsing = False) and (Init.RGB2IsOpen = True)))
      Then
    begin
      Colorizer.DropDownItems.Item[0].Enabled := True;
      if (Init.BWIsOpen = True) and (Init.RGB1IsOpen = True) and (Init.RGB2IsUsing = False)
      Then
      begin
        var args: Arguments;
        SetLength(args, 2);
        args[0] := 1;
        args[1] := 0;
        var ColorizationThread: System.Threading.Thread;
        ColorizationThread := new System.Threading.Thread(VisualizeColorization);
        ColorizationThread.Start(args);
      end
      Else
      if (Init.BWIsOpen = True) and (Init.RGB1IsOpen = True) and (Init.RGB2IsOpen = True) and (Init.RGB2IsUsing = True)
      Then
      begin
        var args: Arguments;
        SetLength(args, 2);
        args[0] := 1;
        args[1] := 1;
        var ColorizationThread: System.Threading.Thread;
        ColorizationThread := new System.Threading.Thread(VisualizeColorization);
        ColorizationThread.Start(args);
      end;
    end;
  end;
end;

procedure ConnectRGB2(sender: object; E: System.EventArgs);
begin
  if Init.RGB2IsUsing = False
  Then
  begin
    Init.RGB2IsUsing := True;
    ColorExamplesMenuItem.DropDownItems.Item[1].Enabled := True;
    RGB2Label.Enabled := True;
    RGB2Image.Enabled := True;
  end
  Else
  begin
    Init.RGB2IsUsing := False;
    ColorExamplesMenuItem.DropDownItems.Item[1].Enabled := False;
    RGB2Label.Enabled := False;
    RGB2Image.Enabled := False;
  end;
  if (Init.RGB2IsUsing = True) and (Init.RGB2IsOpen = False)
    Then
  begin
    Colorizer.DropDownItems.Item[0].Enabled := False;
    Save.DropDownItems.Item[0].Enabled := False;
  end
  Else
  begin
    Colorizer.DropDownItems.Item[0].Enabled := True;
    if WasConverted = True
      Then Save.DropDownItems.Item[0].Enabled := True;
    if (Init.BWIsOpen = True) and (Init.RGB1IsOpen = True)
    Then
    begin
      var args: Arguments;
      SetLength(args, 2);
      args[0] := 1;
      args[1] := 0;
      var ColorizationThread: System.Threading.Thread;
      ColorizationThread := new System.Threading.Thread(VisualizeColorization);
      ColorizationThread.Start(args);
    end;
  end;
  if (Init.BWIsOpen = True) and (Init.RGB1IsOpen = True) and (Init.RGB2IsOpen = True) and (Init.RGB2IsUsing = True)
    Then
  begin
    var args: Arguments;
    SetLength(args, 2);
    args[0] := 1;
    args[1] := 1;
    var ColorizationThread: System.Threading.Thread;
    ColorizationThread := new System.Threading.Thread(VisualizeColorization);
    ColorizationThread.Start(args);
  end;
end;

procedure SaveResult(sender: object; E: EventArgs);
begin
  var SaveColorizedPicture: System.Windows.Forms.SaveFileDialog;
  SaveColorizedPicture := new System.Windows.Forms.SaveFileDialog;
  SaveColorizedPicture.Title := 'Сохранение расцвеченного изображения';
  SaveColorizedPicture.Filter := 'Изображение JPEG|*.jpg|Изображение BMP|*.bmp|Изображение PNG|*.png';
  if SaveColorizedPicture.ShowDialog = System.Windows.Forms.DialogResult.OK
  Then
  begin
    case SaveColorizedPicture.FilterIndex of
      1: Result.Save(SaveColorizedPicture.FileName, System.Drawing.Imaging.ImageFormat.Jpeg);
      2: Result.Save(SaveColorizedPicture.FileName, System.Drawing.Imaging.ImageFormat.Bmp);
      3: Result.Save(SaveColorizedPicture.FileName, System.Drawing.Imaging.ImageFormat.Png);
    End;
  end;
end;

begin
  Init.BWIsOpen := False;
  Init.RGB1IsOpen := False;
  Init.RGB2IsOpen := False;
  Init.RGB2IsUsing := False;
  IsInitialized.BW := False;
  IsInitialized.RGB1 := False;
  IsInitialized.RGB2 := False;
  WasConverted := False;
  MainForm := new System.Windows.Forms.Form;
  MainForm.Text := 'Окрашивание изображений';
  MainForm.ClientSize := new System.Drawing.Size(910, 400);
  MainForm.FormBorderStyle := FormBorderStyle.FixedSingle;
  MainForm.MaximizeBox := False;
  MainForm.MinimizeBox := False;
  MainForm.Icon := System.Drawing.Icon.FromHandle((new System.Drawing.Bitmap(GetResourceStream('5.jpg'))).GetHicon);
  MainToolStrip := new System.Windows.Forms.ToolStrip();
  Colorizer := new System.Windows.Forms.ToolStripMenuItem('Окрашивание');
  Colorizer.DropDownItems.Add(new System.Windows.Forms.ToolStripMenuItem('Окрасить', new System.Drawing.Bitmap(GetResourceStream('2.jpg')), Colorize));
  Colorizer.DropDownItems.Item[0].Enabled := False;
  MainToolStrip.Items.Add(Colorizer);
  ColorExamplesMenuItem := new System.Windows.Forms.ToolStripMenuItem('Источники цвета');
  ColorExamplesMenuItem.DropDownItems.Add(new System.Windows.Forms.ToolStripMenuItem('Изображение №1', new System.Drawing.Bitmap(GetResourceStream('4.jpg')), AddRGB1));
  ColorExamplesMenuItem.DropDownItems.Add(new System.Windows.Forms.ToolStripMenuItem('Изображение №2', new System.Drawing.Bitmap(GetResourceStream('4.jpg')), AddRGB2));
  ColorExamplesMenuItem.DropDownItems.Item[1].Enabled := False;
  MainToolStrip.Items.Add(ColorExamplesMenuItem);
  BWMenuItem := new System.Windows.Forms.ToolStripMenuItem('Чёрно-Белое изображение');
  BWMenuItem.DropDownItems.Add(new System.Windows.Forms.ToolStripMenuItem('Добавить', new System.Drawing.Bitmap(GetResourceStream('3.jpg')), AddBW));
  MainToolStrip.Items.Add(BWMenuItem);
  Save := new System.Windows.Forms.ToolStripMenuItem('Сохранить');
  Save.DropDownItems.Add(new System.Windows.Forms.ToolStripMenuItem('Сохранить расцвеченное изображение', nil, SaveResult));
  Save.DropDownItems.Item[0].Enabled := False;
  MainToolStrip.Items.Add(Save);
  MainForm.Controls.Add(MainToolStrip);
  BWLabel := new System.Windows.Forms.Label;
  BWLabel.Text := 'Чёрно-Белое';
  BWLabel.Top := MainToolStrip.Height + 10;
  BWLabel.Left := 105;
  MainForm.Controls.Add(BWLabel);
  BWImage := new System.Windows.Forms.PictureBox;
  BWImage.BackColor := System.Drawing.Color.White;
  BWImage.Top := BWLabel.Top + BWLabel.Height + 10;
  BWImage.Left := 10;
  BWImage.Width := 290;
  BWImage.Height := 400 - BWImage.Top - 60;
  MainForm.Controls.Add(BWImage);
  RGB1Label := new System.Windows.Forms.Label();
  RGB1Label.Text := 'Цвет №1';
  RGB1Label.Top := BWLabel.Top;
  RGB1Label.Left := 425;
  MainForm.Controls.Add(RGB1Label);
  RGB1Image := new System.Windows.Forms.PictureBox();
  RGB1Image.BackColor := System.Drawing.Color.White;
  RGB1Image.Size := BWImage.Size;
  RGB1Image.Top := BWImage.Top;
  RGB1Image.Left := 310;
  MainForm.Controls.Add(RGB1Image);
  UseRGB2 := new System.Windows.Forms.CheckBox;
  UseRGB2.Top := RGB1Label.Top;
  UseRGB2.Left := 720;
  UseRGB2.Width := 25;
  UseRGB2.Click += ConnectRGB2;
  MainForm.Controls.Add(UseRGB2);
  RGB2Label := new System.Windows.Forms.Label();
  RGB2Label.Text := 'Цвет №2';
  RGB2Label.Top := RGB1Label.Top;
  RGB2Label.Left := 745;
  RGB2Label.Enabled := False;
  MainForm.Controls.Add(RGB2Label);
  RGB2Image := new System.Windows.Forms.PictureBox();
  RGB2Image.BackColor := System.Drawing.Color.White;
  RGB2Image.Size := RGB1Image.Size;
  RGB2Image.Top := RGB1Image.Top;
  RGB2Image.Left := 610;
  RGB2Image.Enabled := False;
  MainForm.Controls.Add(RGB2Image);
  Progress := new System.Windows.Forms.ProgressBar();
  Progress.Width := 910;
  Progress.Height := 50;
  Progress.Top := 350;
  Progress.Style := System.Windows.Forms.ProgressBarStyle.Continuous;
  MainForm.Controls.Add(Progress);
  Application.Run(MainForm);
end.