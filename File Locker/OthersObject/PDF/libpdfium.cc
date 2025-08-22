#ifdef _WINDOWS
#include <windows.h>
#endif



#include "libpdfium.h"

#define IS_REF(i) (i && *i && (*i == &(*(*i))->Reference))

//#define TRACE
#ifdef TRACE
#include <stdio.h>
DWORD wOut;
#define LOG(s)                                                              \
  {                                                                         \
    AllocConsole();                                                         \
    WriteConsoleA(GetStdHandle(STD_OUTPUT_HANDLE), s, strlen(s), &wOut, 0); \
  }
#define REF(i)                                      \
  if (i == 0 /*|| !*i || (*i != (*i)->Reference)*/) \
    LOG("NULL Interface !!!\n")                     \
  if (*i == 0)                                      \
    LOG("NULL Reference !!!\n")                     \
  if (*i != (*i)->Reference)                        \
    LOG("INVALID Reference\n")                      \
  if (!(*i)->Handle)                                \
  LOG("INVALID HANDLE\n")
#else
#define LOG(s)
#define REF(i)
#endif

#ifdef _WINDOWS
// DLL Main
BOOL APIENTRY DllMain( HMODULE hModule,
                       DWORD  ul_reason_for_call,
                       LPVOID lpReserved
                     )
{
    switch (ul_reason_for_call)
    {
    case DLL_PROCESS_ATTACH:
    case DLL_THREAD_ATTACH:
    case DLL_THREAD_DETACH:
    case DLL_PROCESS_DETACH:
        break;
    }
    return TRUE;
}
#endif

// dummy QueryInterface

int PDF_SDK_API QueryInterface(void *self, void *rrid, void *out) {
  LOG("QueryInterface\n")
  return 0x80004001; // E_NOTIMPL
}

// generic function
 void PDF_SDK_API PDF_FreeHandle(IPDFium pdf) {
 // IUnknown->Release, can be used with any object
  LOG("FreeHandle\n")
  (*pdf)->Release(pdf);
}

// forward
int PDF_SDK_API PDF_Free(IPDFium pdf);
int PDF_SDK_API PDFPage_Free(IPDFPage page);
int PDF_SDK_API PDFText_Free(IPDFText text);
int PDF_SDK_API PDFSearchText_Free(IPDFSearchText search);

// IPDFBookmark

int InternalGetBookmark(IPDFium pdf, FPDF_BOOKMARK parent, IPDFBookmark *bookmark); // forward

int PDF_SDK_API PDFBookmark_AddRef(IPDFBookmark bookmark) {
  LOG("PDFBookmark_AddRef\n")
  REF(bookmark)
  return ++(*bookmark)->RefCount;
}

int PDF_SDK_API PDFBookmark_Free(IPDFBookmark bookmark) {
  LOG("PDFBookmark_Free\n")
  REF(bookmark)
  int i =--(*bookmark)->RefCount;
  if (i == 0) {
    PDF_Free((*bookmark)->PDF);
	delete (*bookmark)->Reference;
  } 
  return i;
}

int PDF_SDK_API PDFBookmark_GetPageNumber(IPDFBookmark bookmark) {
  LOG("PDFBookmark_GetPageNumber\n")
  REF(bookmark)
  FPDF_DOCUMENT doc = (*(*bookmark)->PDF)->Handle; 
  FPDF_DEST dest = FPDFBookmark_GetDest(doc, (*bookmark)->Handle);
  if (dest) {
	  return FPDFDest_GetDestPageIndex(doc, dest);
  }  
  return -1; 
}

int PDF_SDK_API PDFBookmark_GetTitle(IPDFBookmark bookmark, PChar title, unsigned long size) {
  LOG("PDFBookmark_GetTitle\n")
  REF(bookmark)
  return FPDFBookmark_GetTitle((*bookmark)->Handle, title, size);
}

int PDF_SDK_API PDFBookmark_GetFirstChild(IPDFBookmark bookmark, IPDFBookmark *child) {
  LOG("PDFBookmark_GetFirstChild\n")
  return InternalGetBookmark((*bookmark)->PDF, (*bookmark)->Handle, child); 
}

int PDF_SDK_API PDFBookmark_GetNext(IPDFBookmark bookmark) {
  LOG("PDFBookmark_GetNext\n")
  REF(bookmark)
  FPDF_DOCUMENT doc = (*(*bookmark)->PDF)->Handle;
  FPDF_BOOKMARK next = FPDFBookmark_GetNextSibling(doc, (*bookmark)->Handle);
  if (next) {
	  (*bookmark)->Handle = next;
	  return 0;
  }
  return 1;
}

int InternalGetBookmark(IPDFium pdf, FPDF_BOOKMARK parent, IPDFBookmark *bookmark) {
	REF(pdf)
		if (IS_REF(bookmark))
			PDFBookmark_Free(*bookmark);
	FPDF_BOOKMARK Handle = FPDFBookmark_GetFirstChild((*pdf)->Handle, parent);
	if (Handle) {
		TPDFBookmark* PDFBookmark = new TPDFBookmark();
		// Internal
		(*pdf)->RefCount++;
		PDFBookmark->PDF = pdf;
		PDFBookmark->Handle = Handle;
		PDFBookmark->Reference = PDFBookmark;
		PDFBookmark->RefCount = 1;
		// IUnknown
		PDFBookmark->QueryInterface = QueryInterface;
		PDFBookmark->AddRef = PDFBookmark_AddRef;
		PDFBookmark->Release = PDFBookmark_Free;
		// IPDFBookmark
		PDFBookmark->GetPageNumber = PDFBookmark_GetPageNumber;
		PDFBookmark->GetTitle = PDFBookmark_GetTitle;
		PDFBookmark->GetFirstChild = PDFBookmark_GetFirstChild;
		PDFBookmark->GetNext = PDFBookmark_GetNext;
		// Result
		*bookmark = &PDFBookmark->Reference;
		return 0;
	}
	return 1;
}

// IPDFAnnotation

int PDF_SDK_API PDFAnnotation_AddRef(IPDFAnnotation annotation) {
  LOG("PDFAnnotation_AddRef\n")
  REF(annotation)
  return ++(*annotation)->RefCount;
}

int PDF_SDK_API PDFAnnotation_Free(IPDFAnnotation annotation) {
  LOG("PDFAnnotation_Free\n")
  REF(annotation)
  int i = --(*annotation)->RefCount;
  if (i == 0) {
    if ((*annotation)->Handle)
      FPDFPage_CloseAnnot((*annotation)->Handle);
    PDFPage_Free((*annotation)->Page);
    LOG("delete annotation\n")
    delete (*annotation)->Reference;
  }
  return i;
}

int PDF_SDK_API PDFAnnotation_GetSubtype(IPDFAnnotation annotation) {
  LOG("PDFAnnotation_GetSubtype\n")
  REF(annotation)
  return FPDFAnnot_GetSubtype((*annotation)->Handle);
}

int PDF_SDK_API PDFAnnotation_GetRect(IPDFAnnotation annotation, TRectF *rect) {
  LOG("PDFAnnotation_GetRect\n")
  REF(annotation)
  return FPDFAnnot_GetRect((*annotation)->Handle, (FS_LPRECTF)rect);
}

int PDF_SDK_API PDFAnnotation_SetRect(IPDFAnnotation annotation, TRectF *rect) {
  LOG("PDFAnnotation_SetRect\n")
  REF(annotation)
  return FPDFAnnot_SetRect((*annotation)->Handle, (FS_LPRECTF)rect);
}

int PDF_SDK_API PDFAnnotation_GetString(IPDFAnnotation annotation, const PAnsiChar key, PChar str, int size) {
  LOG("PDFAnnotation_GetString\n")
  REF(annotation)
  return FPDFAnnot_GetStringValue((*annotation)->Handle, key, str, size);
}

int PDF_SDK_API PDFAnnotation_Remove(IPDFAnnotation annotation) {
  LOG("PDFAnnotation_Remove\n")
  REF(annotation)
  if (!(*annotation)->Handle) return 0;
  FPDFPage_CloseAnnot((*annotation)->Handle);
  (*annotation)->Handle = 0;
  return FPDFPage_RemoveAnnot((*(*annotation)->Page)->Handle, (*annotation)->Index);
}

// IPDFSearchText

int PDF_SDK_API PDFSearchText_AddRef(IPDFSearchText search) {
	LOG("PDFSearchText_AddRef")
	REF(search)
	return ++(*search)->RefCount;
}

int PDF_SDK_API PDFSearchText_Free(IPDFSearchText search) {
  LOG("PDFSearchText_Free\n")
  REF(search)
  int i = --(*search)->RefCount;
  if (i == 0) {
    FPDFText_FindClose((*search)->Handle);
    PDFText_Free((*search)->Text);
    delete (*search)->Reference;
  }
  return i;
}

int PDF_SDK_API PDFSearchText_FindNext(IPDFSearchText search) {
  LOG("PDFSearchText_FindNext\n")
	REF(search)
	return FPDFText_FindNext((*search)->Handle);
}

int PDF_SDK_API PDFSearchText_FindPrev(IPDFSearchText search) {
  LOG("PDFSearchText_FindPrev\n")
	REF(search)
	return FPDFText_FindPrev((*search)->Handle);
}

int PDF_SDK_API PDFSearchText_GetPosition(IPDFSearchText search, int *start, int *length) {
  LOG("PDFSearchText_GetPosition\n")
	REF(search)
	*start = FPDFText_GetSchResultIndex((*search)->Handle);
	*length = FPDFText_GetSchCount((*search)->Handle);
	return 0;
}

// IPDFText

int PDF_SDK_API PDFText_AddRef(IPDFText text) {
  LOG("PDFText_AddRef\n")
  REF(text)
  return ++(*text)->RefCount;
}

int PDF_SDK_API PDFText_Free(IPDFText text) {
  LOG("PDFText_Free\n")
  REF(text)
  int i = --(*text)->RefCount;
  if (i == 0) {
    FPDFText_ClosePage((*text)->Handle);
    PDFPage_Free((*text)->Page);
    LOG("delete text\n")
    delete (*text)->Reference;
  }
  return i;
}

int PDF_SDK_API PDFText_CharCount(IPDFText text) {
  REF(text)
  return FPDFText_CountChars((*text)->Handle);
}

int PDF_SDK_API PDFText_GetText(IPDFText text, int Start, int Length, PChar Text) {
  REF(text)
  return FPDFText_GetText((*text)->Handle, Start, Length, Text);
}

int PDF_SDK_API PDFText_CharIndexAtPos(IPDFText text, TPointsSize *size, int distance) {
  REF(text)
  return FPDFText_GetCharIndexAtPos((*text)->Handle, size->cx, size->cy, distance, distance);
}

int PDF_SDK_API PDFText_GetRectCount(IPDFText text, int Start, int Length) {
  REF(text)
  return FPDFText_CountRects((*text)->Handle, Start, Length);	
}

int PDF_SDK_API PDFText_GetRect(IPDFText text, int Index, TRectD *rect) {
  REF(text)
  return FPDFText_GetRect((*text)->Handle, Index, &rect->Left, &rect->Top, &rect->Right, &rect->Bottom);
}

int PDF_SDK_API PDFText_Search(IPDFText text, const PChar what, unsigned long flags, int start_index, IPDFSearchText *search) {
	LOG("PDFText_Search\n")
	REF(text)
	if (IS_REF(search))
		PDFSearchText_Free(*search);
	FPDF_SCHHANDLE Handle = FPDFText_FindStart((*text)->Handle, (FPDF_WIDESTRING)what, flags, start_index);
	if (Handle) {
		TPDFSearchText* PDFSearchText = new TPDFSearchText();
		// Internal
		(*text)->RefCount++;
		PDFSearchText->Text = text;
		PDFSearchText->Handle = Handle;
		PDFSearchText->Reference = PDFSearchText;
		PDFSearchText->RefCount = 1;
		// IUnknown
		PDFSearchText->QueryInterface = QueryInterface;
		PDFSearchText->AddRef = PDFSearchText_AddRef;
		PDFSearchText->Release = PDFSearchText_Free;
		// IPDFSearchText
		PDFSearchText->FindNext = PDFSearchText_FindNext;
		PDFSearchText->FindPrev = PDFSearchText_FindPrev;
		PDFSearchText->GetPosition = PDFSearchText_GetPosition;
		// Result
		*search = &PDFSearchText->Reference;
		return 1;
	}
	return 0;
}

// IPDFBitmap

int PDF_SDK_API PDFBitmap_AddRef(IPDFBitmap bitmap) {
	LOG("PDFBitmap_AddRef\n")
	REF(bitmap)
	return ++(*bitmap)->RefCount;
}

int PDF_SDK_API PDFBitmap_Free(IPDFBitmap bitmap) {
	LOG("PDFBitmap_Free\n")
	REF(bitmap)
	int i = --(*bitmap)->RefCount;
	if (i == 0) {
		FPDFBitmap_Destroy((*bitmap)->Handle);
		delete (*bitmap)->Reference;
	}
	return i;
}

int PDF_SDK_API PDFBitmap_Draw(IPDFBitmap bitmap, HDC dc, int x, int y) {
	LOG("PDFBitmap_Draw\n")
	REF(bitmap)
#ifdef _WINDOWS
	if (!dc) return false;
	int w = FPDFBitmap_GetWidth((*bitmap)->Handle);
	int h = FPDFBitmap_GetHeight((*bitmap)->Handle);
	void* p = FPDFBitmap_GetBuffer((*bitmap)->Handle);
	BITMAPINFO bi;
	memset(&bi, 0, sizeof(bi));
	bi.bmiHeader.biSize = 40;
	bi.bmiHeader.biWidth = w;
	bi.bmiHeader.biHeight = -h;
	bi.bmiHeader.biPlanes = 1;
	bi.bmiHeader.biBitCount = 32;
	SetDIBitsToDevice(dc, x, y, w, h, 0, 0, 0, h, p, &bi, 0);
#endif
	return true;
}

int PDF_SDK_API PDFBitmap_GetInfo(IPDFBitmap bitmap, TPDFBitmapInfo* info) {
	LOG("PDFBitmap_GetInfo\n")
	REF(bitmap)
	if (!info)
        return 0;
	info->Format = FPDFBitmap_GetFormat((*bitmap)->Handle);
	info->Width = FPDFBitmap_GetWidth((*bitmap)->Handle);
	info->Height = FPDFBitmap_GetHeight((*bitmap)->Handle);
	info->Stride = FPDFBitmap_GetStride((*bitmap)->Handle);
	info->Buffer = FPDFBitmap_GetBuffer((*bitmap)->Handle);
	return 1;
}

// IPDFPage

int PDF_SDK_API PDFPage_AddRef(IPDFPage page) {
  LOG("PDFPage_AddRef\n")
  REF(page)
  return ++(*page)->RefCount;
}

int PDF_SDK_API PDFPage_Free(IPDFPage page) {
  LOG("PDFPage_Free\n")
  REF(page)
  int i = --(*page)->RefCount;
  if (i == 0) {
    FPDF_ClosePage((*page)->Handle);
    PDF_Free((*page)->PDF);
    LOG("delete page\n")
    delete (*page)->Reference;
  }
  return i;
}

int PDF_SDK_API PDFPage_Render(IPDFPage page, HDC dc, TRect* rect, int rotation, int flags) {
  LOG("PDFPage_Render\n")
  REF(page)
#ifdef _WINDOWS
  FPDF_RenderPage(dc, (*page)->Handle, rect->Left, rect->Top, rect->Right - rect->Left, rect->Bottom - rect->Top, rotation, flags);
#endif
  return 0;
}

int PDF_SDK_API PDFPage_GetAnnotationCount(IPDFPage page) {
  LOG("PDFPage_GetAnnotationCount\n")
  REF(page)
  return FPDFPage_GetAnnotCount((*page)->Handle);
}

int PDF_SDK_API PDFPage_GetAnnotation(IPDFPage page, int annotation_index, IPDFAnnotation *annotation) {
  LOG("PDFPage_GetAnnotation\n")
  REF(page)
  if (IS_REF(annotation))
    PDFAnnotation_Free(*annotation);
  FPDF_ANNOTATION Handle = FPDFPage_GetAnnot((*page)->Handle, annotation_index);
  if (Handle) {
    TPDFAnnotation *PDFAnnotation = new TPDFAnnotation();
  // Internal
    (*page)->RefCount++;
    PDFAnnotation->Page = page;
    PDFAnnotation->Index = annotation_index;
    PDFAnnotation->Handle = Handle;
    PDFAnnotation->Reference = PDFAnnotation;
    PDFAnnotation->RefCount = 1;
  // IUnknown
    PDFAnnotation->QueryInterface = QueryInterface;
    PDFAnnotation->AddRef = PDFAnnotation_AddRef;
    PDFAnnotation->Release = PDFAnnotation_Free;
  // IPDFAnnotation
    PDFAnnotation->GetSubtype = PDFAnnotation_GetSubtype;
    PDFAnnotation->GetRect = PDFAnnotation_GetRect;
    PDFAnnotation->SetRect = PDFAnnotation_SetRect;
    PDFAnnotation->GetString = PDFAnnotation_GetString;
    PDFAnnotation->Remove = PDFAnnotation_Remove;
  // Result
    *annotation = &PDFAnnotation->Reference;
    return 0;
  }
  return 1;	
}

int PDF_SDK_API PDFPage_GetText(IPDFPage page, IPDFText *text) {
  LOG("PDFPage_GetText\n")
  REF(page)
  if (IS_REF(text))
    PDFText_Free(*text);
  FPDF_TEXTPAGE Handle = FPDFText_LoadPage((*page)->Handle);
  if (Handle) {
    TPDFText *PDFText = new TPDFText();
  // Internal 
    (*page)->RefCount++;
    PDFText->Page = page;
    PDFText->Handle = Handle;
    PDFText->Reference = PDFText;
    PDFText->RefCount = 1;
  // IUnknown
    PDFText->QueryInterface = QueryInterface;
    PDFText->AddRef = PDFText_AddRef;
    PDFText->Release = PDFText_Free;
  // IPDFText
    PDFText->CharCount = PDFText_CharCount;
    PDFText->GetText = PDFText_GetText;
    PDFText->CharIndexAtPos = PDFText_CharIndexAtPos;
    PDFText->GetRectCount = PDFText_GetRectCount;
    PDFText->GetRect = PDFText_GetRect;
    PDFText->Search = PDFText_Search;
  // Result
    *text = &PDFText->Reference;
    return 0;
  }
  return 1;
}

void PDF_SDK_API PDFPage_DeviveToPage(IPDFPage page, TRect *rect, int x, int y, double *px, double *py) {
  REF(page)
  FPDF_DeviceToPage((*page)->Handle, rect->Left, rect->Top, rect->Right - rect->Left, rect->Bottom - rect->Top, 0, x, y, px, py);
}

void PDF_SDK_API PDFPage_PageToDevice(IPDFPage page, TRect *rect, double px, double py, int *x, int *y) {
  REF(page)
  FPDF_PageToDevice((*page)->Handle, rect->Left, rect->Top, rect->Right - rect->Left, rect->Bottom - rect->Top, 0, px, py, x, y);
}

int PDF_SDK_API PDFPage_GetRotation(IPDFPage page) {
  LOG("PDFPage_GetRotation\n")
  REF(page)
  return FPDFPage_GetRotation((*page)->Handle);
}

int PDF_SDK_API PDFPage_GetBitmap(IPDFPage page, TRect *pageRect, TRect *viewPort, int rotation, int flags, IPDFBitmap *bitmap) {
	LOG("PDFPage_GetBitmap\n")
	REF(page)
	if IS_REF(bitmap)
		PDFBitmap_Free(*bitmap);
	int width = viewPort->Right - viewPort->Left;
	int height = viewPort->Bottom - viewPort->Top;    
    FPDF_BITMAP Handle = FPDFBitmap_Create(width, height, 0);
	if (!Handle) return false;

	FPDFBitmap_FillRect(Handle, 0, 0, width, height, 0xFFFFFFFF);
	int x = pageRect->Left - viewPort->Left;
	int y = pageRect->Top - viewPort->Top;
	int w = pageRect->Right - pageRect->Left;
	int h = pageRect->Bottom - pageRect->Top;  
	FPDF_RenderPageBitmap(Handle, (*page)->Handle, x, y, w, h, rotation, flags);

	FPDF_DOCUMENT doc = (*(*page)->PDF)->Handle;
    FPDF_FORMFILLINFO info = {0};
	//memset(&info, 0, sizeof(info));
	info.version = 1; 
	FPDF_FORMHANDLE form = FPDFDOC_InitFormFillEnvironment(doc, &info);
	FPDF_FFLDraw(form, Handle, (*page)->Handle, x, y, w, h, rotation, flags);
	FPDFDOC_ExitFormFillEnvironment(form);

	TPDFBitmap* PDFBitmap = new TPDFBitmap();
	// Internal
	PDFBitmap->Handle = Handle;
	PDFBitmap->Reference = PDFBitmap;
	PDFBitmap->RefCount = 1;
	// IUnknown
	PDFBitmap->QueryInterface = QueryInterface;
	PDFBitmap->AddRef = PDFBitmap_AddRef;
	PDFBitmap->Release = PDFBitmap_Free;
	// IPDFBitmap
	PDFBitmap->Draw = PDFBitmap_Draw;
	PDFBitmap->GetInfo = PDFBitmap_GetInfo;
	// Result
	*bitmap = &PDFBitmap->Reference;
	return true;
}

// IPDFium

int __stdcall PDF_AddRef(IPDFium pdf) {
  LOG("PDF_AddRef\n")
  REF(pdf)
  return ++(*pdf)->RefCount;
}

int PDF_SDK_API PDF_Free(IPDFium pdf) {
  LOG("PDF_Free\n")
  REF(pdf)
  int i = --(*pdf)->RefCount;
  if (i == 0) {
   	LOG("FPDF_CloseDocument\n")
    if ((*pdf)->Handle) FPDF_CloseDocument((*pdf)->Handle);
    LOG("delete pdf\n")
    delete (*pdf)->Reference;
  }
  return i;
}

int PDF_SDK_API PDF_GetVersion(IPDFium pdf) {
  LOG("PDF_GetVersion\n")
  REF(pdf)
  return (*pdf)->Version;
}

int PDF_SDK_API PDF_GetError(IPDFium pdf) {
  LOG("PDF_GetError\n")
  REF(pdf)
  return (int)FPDF_GetLastError();
}

int PDF_SDK_API PDF_CloseDocument(IPDFium pdf) {
  LOG("PDF_CloseDocument\n")
  REF(pdf)
  if ((*pdf)->Handle) FPDF_CloseDocument((*pdf)->Handle);
  (*pdf)->Handle = 0;
  return 0;
}

int PDF_SDK_API PDF_LoadFromFile(IPDFium pdf, PAnsiChar filename, PAnsiChar pwd) {
  LOG("PDF_LoadFromFile\n")
  REF(pdf)
  if ((*pdf)->Handle) FPDF_CloseDocument((*pdf)->Handle);
  (*pdf)->Handle = FPDF_LoadDocument(filename, pwd);
  return (*pdf)->Handle ? 0 : (int)FPDF_GetLastError();
}

int PDF_SDK_API PDF_LoadFromMemory(IPDFium pdf, void* data, int size, PAnsiChar pwd) {
  LOG("PDF_LoadFromMemory\n")
  REF(pdf)	
  if ((*pdf)->Handle) FPDF_CloseDocument((*pdf)->Handle);
  (*pdf)->Handle = FPDF_LoadMemDocument(data, size, pwd);
  return (*pdf)->Handle ? 0 : (int)FPDF_GetLastError();
}

long PDF_SDK_API PDF_GetPermissions(IPDFium pdf) {
  REF(pdf)
  return FPDF_GetDocPermissions((*pdf)->Handle);
}

int PDF_SDK_API PDF_GetPageCount(IPDFium pdf) {
 LOG("PDF_GetPageCount\n")
  REF(pdf)
  return FPDF_GetPageCount((*pdf)->Handle);
}

int PDF_SDK_API PDF_GetPageSize(IPDFium pdf, int page_index, TPointsSizeF *size) {
  LOG("PDF_GetPageSize\n")
  REF(pdf)
  return FPDF_GetPageSizeByIndexF((*pdf)->Handle, page_index, (FS_SIZEF*)size);
}

int PDF_SDK_API PDF_GetPage(IPDFium pdf, int page_index, IPDFPage* page) {
  LOG("PDF_GetPage\n")
  REF(pdf)
  if (IS_REF(page))
    PDFPage_Free(*page);
  FPDF_PAGE Handle = FPDF_LoadPage((*pdf)->Handle, page_index);
  if (Handle) {
    TPDFPage *PDFPage = new TPDFPage();
  // Internal
    (*pdf)->RefCount++;
    PDFPage->PDF = pdf;
    PDFPage->Handle = Handle;
    PDFPage->Reference = PDFPage;
    PDFPage->RefCount = 1;
  // IUnknown
    PDFPage->QueryInterface = QueryInterface;
    PDFPage->AddRef = PDFPage_AddRef;
    PDFPage->Release = PDFPage_Free;
  // IPDFPage
    PDFPage->Render = PDFPage_Render;
    PDFPage->GetAnnotationCount = PDFPage_GetAnnotationCount;
    PDFPage->GetAnnotation = PDFPage_GetAnnotation;
    PDFPage->GetText = PDFPage_GetText;
    PDFPage->DeviveToPage = PDFPage_DeviveToPage;
    PDFPage->PageToDevice = PDFPage_PageToDevice;
		PDFPage->GetRotation = PDFPage_GetRotation;
    PDFPage->GetBitmap = PDFPage_GetBitmap;
  // Result
    *page = &PDFPage->Reference;
    return 0;
  }
  return 1;
}

typedef struct {
  FPDF_FILEWRITE FW;
  TWriteProc writeProc;
  IStream Stream;
} TWriteStream, *PWriteStream;

int WriteStream(struct FPDF_FILEWRITE_* pThis, const void* pData, unsigned long size) {
  ULONG pcbWritten;
  if ((*((PWriteStream)pThis)->Stream)->Write(((PWriteStream)pThis)->Stream, pData, size, &pcbWritten) == 0)
    return pcbWritten;
  return 0;
}

int PDF_SDK_API PDF_SaveToStream(IPDFium pdf, IStream stream) {
  LOG("PDF_SaveToStream\n")
  REF(pdf)
  TWriteStream WS;
  WS.FW.version = 1;
  WS.FW.WriteBlock = WriteStream;
  WS.Stream = stream;
  int ret = FPDF_SaveAsCopy((*pdf)->Handle, &WS.FW, 0);
  (*stream)->Release(stream);
  return ret;
}

typedef struct {
  FPDF_FILEWRITE FW;
  TWriteProc writeProc;
  void* userData;
} TFileWrite, *PFileWrite;

int WriteBlock(struct FPDF_FILEWRITE_* pThis, const void* pData, unsigned long size) {
  return ((PFileWrite)pThis)->writeProc(pData, size, ((PFileWrite)pThis)->userData);
}

int PDF_SDK_API PDF_SaveToProc(IPDFium pdf, TWriteProc writeProc, void *userData) {
  LOG("PDF_SaveToProc\n")
  REF(pdf)
  TFileWrite FW;
  FW.FW.version = 1;
  FW.FW.WriteBlock = WriteBlock;
  FW.writeProc = writeProc;
  FW.userData = userData;
  return FPDF_SaveAsCopy((*pdf)->Handle, &FW.FW, 0);
}

int PDF_SDK_API PDF_GetFirstBookmark(IPDFium pdf, IPDFBookmark *bookmark) {
  LOG("PDF_GetFirstBookmark\n")
  return InternalGetBookmark(pdf, NULL, bookmark);
}

int PDF_SDK_API PDF_GetMetaText(IPDFium pdf, const PAnsiChar name, PChar value, int valueSize) {
  LOG("PDF_GetMetaText\n")
  REF(pdf)
  return FPDF_GetMetaText((*pdf)->Handle, name, value, valueSize);
}

int initialized = 0;

int PDF_SDK_API PDF_Create(int RequestedVersion, IPDFium* pdf) {
  LOG("PDF_Create\n")
  if (RequestedVersion != PDFIUM_VERSION) return -1;
  if (!initialized) {
    LOG("Initialization\n")
    initialized = 1;
    FPDF_InitLibrary();
  }
  if (IS_REF(pdf))
    PDF_Free(*pdf);
  TPDFium *PDF = new TPDFium();
  // Internal
  PDF->Version = PDFIUM_VERSION;
  PDF->Reference = PDF;
  PDF->RefCount = 1;
  PDF->Handle = 0;
  // IUnknown
  PDF->QueryInterface = QueryInterface;
  PDF->AddRef = PDF_AddRef;
  PDF->Release = PDF_Free;
  // IPDFInterface
  PDF->GetVersion = PDF_GetVersion;
  PDF->GetError = PDF_GetError;
  PDF->CloseDocument = PDF_CloseDocument;
  PDF->LoadFromFile = PDF_LoadFromFile;
  PDF->LoadFromMemory = PDF_LoadFromMemory;
  PDF->GetPermissions = PDF_GetPermissions;
  PDF->GetPageCount = PDF_GetPageCount;
  PDF->GetPageSize = PDF_GetPageSize;
  PDF->GetPage = PDF_GetPage;
  PDF->SaveToStream = PDF_SaveToStream;
  PDF->SaveToProc = PDF_SaveToProc;
  PDF->SaveToProc = PDF_SaveToProc;
  PDF->GetMetaText = PDF_GetMetaText;
  // Result
  *pdf = &PDF->Reference;
  return 0;
}
