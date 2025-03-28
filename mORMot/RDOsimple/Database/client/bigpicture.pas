unit bigpicture;

{$mode delphi}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  ExtDlgs, Menus, Types,
  SynCommons;

type

  { TPhotoForm }

  TPhotoForm = class(TForm)
    Image: TImage;
    MainMenu1: TMainMenu;
    SavePicture: TMenuItem;
    SavePictureDialog1: TSavePictureDialog;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure SavePictureClick(Sender: TObject);
  private
    { private declarations }
    aFileName:string;
  public
    { public declarations }
    class function Show(BigPic:THeapMemoryStream; FileName:string): boolean;
  end;

var
  PhotoForm: TPhotoForm;

implementation

{$R *.lfm}

procedure TPhotoForm.SavePictureClick(Sender: TObject);
begin
  SavePictureDialog1.FileName:=aFileName;
  SavePictureDialog1.DefaultExt:=ExtractFileExt(aFileName);
  if SavePictureDialog1.Execute then
  begin
    Image.Picture.SaveToFile(SavePictureDialog1.FileName);
  end;
end;

procedure TPhotoForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  Image.Picture.Clear;
end;

class function TPhotoForm.Show(BigPic:THeapMemoryStream; FileName:string): boolean;
var
  PhotoForm: TPhotoForm;
  {$ifndef FPC}
  JPEGImage: TJPEGImage;
  {$endif}
begin
  Application.CreateForm(TPhotoForm,PhotoForm);
  with PhotoForm do
  begin
    aFileName:=FileName;
    {$ifdef FPC}
    Image.Picture.LoadFromStream(BigPic);
    {$else}
    JPEGImage := TJPEGImage.Create;
    try
      JPEGImage.LoadFromStream(BigPic);
      Image.Picture.Assign(JPEGImage);
    finally
      JPEGImage.Free;
    end;
    {$endif}
    ShowOnTop;
    PhotoForm.Width:=Image.DestRect.Width+20;
  end;
end;

end.

