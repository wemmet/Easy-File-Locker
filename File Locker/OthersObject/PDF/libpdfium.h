// libdfium v1.0.2 (c)2018-2021 Execute SARL <contact@execute.fr>

#include "fpdfview.h"
#include "fpdf_annot.h"
#include "fpdf_text.h"
#include "fpdf_save.h"
#include "fpdf_edit.h"

#ifndef PUBLIC_FPDFVIEW_H_
typedef void *FPDF_DOCUMENT;
typedef void *FPDF_PAGE;
typedef void *FPDF_TEXTPAGE;
typedef void *FPDF_ANNOTATION;
#endif

#ifdef _WINDOWS
#define  PDF_SDK_API __stdcall
#else
#define  PDF_SDK_API
#endif

#ifndef WINAPI
typedef uint32_t ULONG;
typedef int HDC;
#endif

#define PDFIUM_VERSION 3

#ifdef __cplusplus
extern "C"
{
#endif

typedef int (PDF_SDK_API *TWriteProc)(const void *data, int size, void *UserData);

typedef char *PAnsiChar;
typedef unsigned short *PChar;

typedef struct TStream TStream;
typedef TStream *PStream;
typedef TStream **IStream;

typedef struct TPDFium TPDFium;
typedef TPDFium *PPDFium;
typedef TPDFium **IPDFium;

typedef struct TPDFPage TPDFPage;
typedef TPDFPage *PPDFPage;
typedef TPDFPage **IPDFPage;

typedef struct TPDFText TPDFText;
typedef TPDFText *PPDFText;
typedef TPDFText **IPDFText;

typedef struct TPDFSearchText TPDFSearchText;
typedef TPDFSearchText *PPDFSearchText;
typedef TPDFSearchText **IPDFSearchText;

typedef struct TPDFAnnotation TPDFAnnotation;
typedef TPDFAnnotation *PPDFAnnotation;
typedef TPDFAnnotation **IPDFAnnotation;

typedef struct TPDFBookmark TPDFBookmark;
typedef TPDFBookmark *PPDFBookmark;
typedef TPDFBookmark **IPDFBookmark;

typedef struct TPDFBitmap TPDFBitmap;
typedef TPDFBitmap *PPDFBitmap;
typedef TPDFBitmap **IPDFBitmap;

typedef struct {
  int Format;
  int Width;
  int Height;
  int Stride;
  void* Buffer;
} TPDFBitmapInfo;

typedef struct {
  int Left;
  int Top;
  int Right;
  int Bottom;
} TRect;

typedef struct {
  float Left;
  float Top;
  float Right;
  float Bottom;
} TRectF;

typedef struct {
  double Left;
  double Top;
  double Right;
  double Bottom;
} TRectD;

typedef struct {
  double cx;
  double cy;
} TPointsSize;

typedef struct {
  float cx;
  float cy;
} TPointsSizeF;

struct TStream {
// IUnknown
  int(PDF_SDK_API *QueryInterface)(void *intf, void *rrid, void*);
  int(PDF_SDK_API *AddRef)(IStream stream);
  int(PDF_SDK_API *Release)(IStream stream);
// ISequentialStream
  int(PDF_SDK_API *Read)(IStream stream, const void *pv, ULONG cb, ULONG *pcbRead);
  int(PDF_SDK_API *Write)(IStream stream, const void *pv, ULONG cb, ULONG *pcbWritten);
};

struct TPDFBitmap {
// IUnknwon
	int(PDF_SDK_API *QueryInterface)(void *intf, void *rrid, void*);
	int(PDF_SDK_API *AddRef)(IPDFBitmap bitmap);
	int(PDF_SDK_API *Release)(IPDFBitmap bitmap);
// IDPFBitmap
	int(PDF_SDK_API *Draw)(IPDFBitmap bitmap, HDC dc, int x, int y);
	int(PDF_SDK_API *GetInfo)(IPDFBitmap bitmap, TPDFBitmapInfo* info);
// Internal
	PPDFBitmap Reference;
	int RefCount;
	FPDF_BITMAP Handle;
};

struct TPDFBookmark {
// IUnknwon
	int(PDF_SDK_API *QueryInterface)(void *intf, void *rrid, void*);
	int(PDF_SDK_API *AddRef)(IPDFBookmark bookmark);
	int(PDF_SDK_API *Release)(IPDFBookmark bookmark);
// IPDFBookmark
	int(PDF_SDK_API *GetPageNumber)(IPDFBookmark bookmark);
	int(PDF_SDK_API *GetTitle)(IPDFBookmark bookmark, PChar title, unsigned long size);
	int(PDF_SDK_API *GetFirstChild)(IPDFBookmark bookmark, IPDFBookmark *child);
	int(PDF_SDK_API *GetNext)(IPDFBookmark bookmark);
// Internal
	PPDFBookmark Reference;
	int RefCount;
	IPDFium PDF;
	FPDF_BOOKMARK Handle;
};

struct TPDFAnnotation {
// IUnknown
  int(PDF_SDK_API *QueryInterface)(void *intf, void *rrid, void*);
  int(PDF_SDK_API *AddRef)(IPDFAnnotation annotation);
  int(PDF_SDK_API *Release)(IPDFAnnotation annotation);
// IPDFAnnotation
  int(PDF_SDK_API *GetSubtype)(IPDFAnnotation annotation);
  int(PDF_SDK_API *GetRect)(IPDFAnnotation annotation, TRectF *rect);
  int(PDF_SDK_API *SetRect)(IPDFAnnotation annotation, TRectF *rect);
  int(PDF_SDK_API *GetString)(IPDFAnnotation annotation, const PAnsiChar key, PChar str, int size);
  int(PDF_SDK_API *Remove)(IPDFAnnotation annotation);
// Internal
  PPDFAnnotation Reference;
  int RefCount;
  IPDFPage Page;
  int Index;
  FPDF_ANNOTATION Handle;
};

struct TPDFSearchText {
// IUnknown
  int(PDF_SDK_API *QueryInterface)(void *intf, void *rrid, void *out);
  int(PDF_SDK_API *AddRef)(IPDFSearchText search);
  int(PDF_SDK_API *Release)(IPDFSearchText search);
// IPDFSearchText
  int(PDF_SDK_API *FindNext)(IPDFSearchText search);
  int(PDF_SDK_API *FindPrev)(IPDFSearchText search);
	int(PDF_SDK_API *GetPosition)(IPDFSearchText search, int *Start, int *Length);
// Internal
  PPDFSearchText Reference;
	int RefCount;
	IPDFText Text;
	FPDF_SCHHANDLE Handle;
};

struct TPDFText {
// IUnknown
  int(PDF_SDK_API *QueryInterface)(void *intf, void *rrid, void *out);
  int(PDF_SDK_API *AddRef)(IPDFText text);
  int(PDF_SDK_API *Release)(IPDFText text);
// IPDFText
  int(PDF_SDK_API *CharCount)(IPDFText text);
  int(PDF_SDK_API *GetText)(IPDFText text, int Start, int Length, PChar Text);
  int(PDF_SDK_API *CharIndexAtPos)(IPDFText text, TPointsSize *size, int distance);
  int(PDF_SDK_API *GetRectCount)(IPDFText text, int Start, int Length);
  int(PDF_SDK_API *GetRect)(IPDFText text, int Index, TRectD *rect);
	int(PDF_SDK_API *Search)(IPDFText text, const PChar what, unsigned long flags, int start_index, IPDFSearchText *search);  
// Internal  
  PPDFText Reference;
  int RefCount;
  IPDFPage Page;
  FPDF_TEXTPAGE Handle;
};

struct TPDFPage {
// IUnknown
  int(PDF_SDK_API *QueryInterface)(void *intf, void *rrid, void *out);
  int(PDF_SDK_API *AddRef)(IPDFPage page);
  int(PDF_SDK_API *Release)(IPDFPage page);
// IPDFPage
  int(PDF_SDK_API *Render)(IPDFPage page, HDC dc, TRect *rect, int rotation, int flags);
  int(PDF_SDK_API *GetAnnotationCount)(IPDFPage page);
  int(PDF_SDK_API *GetAnnotation)(IPDFPage page, int annotation_index, IPDFAnnotation *annotation);
  int(PDF_SDK_API *GetText)(IPDFPage page, IPDFText *text);
  void(PDF_SDK_API *DeviveToPage)(IPDFPage page, TRect *rect, int x, int y, double *px, double *py);
  void(PDF_SDK_API *PageToDevice)(IPDFPage page, TRect *rect, double px, double py, int *x, int *y);
	int(PDF_SDK_API *GetRotation)(IPDFPage page);
  int(PDF_SDK_API *GetBitmap)(IPDFPage page, TRect *pageRect, TRect *viewPort, int rotation, int flags, IPDFBitmap* bitmap);
// Internal
  PPDFPage Reference;
  int RefCount;
  IPDFium PDF;
  FPDF_PAGE Handle;
};

struct TPDFium {
// IUnknown
  int(PDF_SDK_API *QueryInterface)(void *intf, void *rrid, void *out);
  int(PDF_SDK_API *AddRef)(IPDFium pdf);
  int(PDF_SDK_API *Release)(IPDFium pdf);
// IPDFium
  int(PDF_SDK_API *GetVersion)(IPDFium pdf);
  int(PDF_SDK_API *GetError)(IPDFium pdf);
  int(PDF_SDK_API *CloseDocument)(IPDFium pdf);
  int(PDF_SDK_API *LoadFromFile)(IPDFium pdf, PAnsiChar filename, PAnsiChar pwd);
  int(PDF_SDK_API *LoadFromMemory)(IPDFium pdf, void *data, int size, PAnsiChar pwd);
  long(PDF_SDK_API *GetPermissions)(IPDFium pdf);
  int(PDF_SDK_API *GetPageCount)(IPDFium pdf);
  int(PDF_SDK_API *GetPageSize)(IPDFium pdf, int page_index, TPointsSizeF *size);
  int(PDF_SDK_API *GetPage)(IPDFium pdf, int page_index, IPDFPage *page);
  int(PDF_SDK_API *SaveToStream)(IPDFium pdf, IStream stream);
  int(PDF_SDK_API *SaveToProc)(IPDFium pdf, TWriteProc writeProc, void *userData);
  int(PDF_SDK_API *GetFirstBookmark)(IPDFium pdf, IPDFBookmark *bookmark);  
  int(PDF_SDK_API *GetMetaText)(IPDFium pdf, const PAnsiChar name, PChar value, int valueSize);
// Internal
  PPDFium Reference;
  int RefCount;
  int PageCount;
  int Version;
  FPDF_DOCUMENT Handle;
};

int PDF_SDK_API PDF_FreeHandle(void *handle);

int PDF_SDK_API PDF_Create(int RequiredVersion, IPDFium *pdf);
int PDF_SDK_API PDF_Free(IPDFium pdf);
int PDF_SDK_API PDF_GetVersion(IPDFium pdf);
int PDF_SDK_API PDF_GetError(IPDFium pdf);
int PDF_SDK_API PDF_CloseDocument(IPDFium pdf);
int PDF_SDK_API PDF_LoadFromFile(IPDFium pdf, char *filename, char *pwd);
int PDF_SDK_API PDF_LoadFromMemory(IPDFium pdf, void *data, int size, char *pwd);
long PDF_SDK_API PDF_GetPermissions(IPDFium pdf);
int PDF_SDK_API PDF_GetPageCount(IPDFium pdf);
int PDF_SDK_API PDF_GetPageSize(IPDFium pdf, int page_index, TPointsSizeF *size);
int PDF_SDK_API PDF_GetPage(IPDFium pdf, int page_index, IPDFPage *page);
int PDF_SDK_API PDF_SaveToStream(IPDFium pdf, IStream stream);
int PDF_SDK_API PDF_SaveToProc(IPDFium pdf, TWriteProc writeProc, void *userData);

int PDF_SDK_API PDFPage_Free(IPDFPage page);
int PDF_SDK_API PDFPage_Render(IPDFPage page, HDC dc, TRect *rect, int rotation, int flags);
int PDF_SDK_API PDFPage_GetBitmap(IPDFPage page, TRect *pageRect, TRect *viewPort, int rotation, int flags, IPDFBitmap *bitmap);
int PDF_SDK_API PDFPage_Paint(IPDFPage page, HDC dc, TRect *rect, int annotation);
int PDF_SDK_API PDFPage_GetAnnotationCount(IPDFPage page);
int PDF_SDK_API PDFPage_GetAnnotation(IPDFPage page, int annotation_index, IPDFAnnotation *annotation);
int PDF_SDK_API PDFPage_GetText(IPDFPage page, IPDFText *text);
void PDF_SDK_API PDFPage_DeviveToPage(IPDFPage page, TRect *rect, int x, int y, double *px, double *py);
void PDF_SDK_API PDFPage_PageToDevice(IPDFPage page, TRect *rect, double px, double py, int *x, int *y);
int PDF_SDK_API PDFPage_GetRotation(IPDFPage page);
int PDF_SDK_API PDFBitmap_Free(IPDFBitmap bitmap);

int PDF_SDK_API PDFBitmap_GetInfo(IPDFBitmap bitmap, TPDFBitmapInfo* info);

int PDF_SDK_API PDFText_Free(IPDFText text);
int PDF_SDK_API PDFText_CharCount(IPDFText text);
int PDF_SDK_API PDFText_GetText(IPDFText text, int Start, int Length, unsigned short *Text);
int PDF_SDK_API PDFText_CharIndexAtPos(IPDFText text, TPointsSize *size, int distance);
int PDF_SDK_API PDFText_GetRectCount(IPDFText text, int Start, int Length);
int PDF_SDK_API PDFText_GetRect(IPDFText text, int Index, TRectD *rect);

int PDF_SDK_API PDFAnnotation_Free(IPDFAnnotation annotation);
int PDF_SDK_API PDFAnnotation_GetSubtype(IPDFAnnotation annotation);
int PDF_SDK_API PDFAnnotation_GetRect(IPDFAnnotation annotation, TRectF *rect);
int PDF_SDK_API PDFAnnotation_SetRect(IPDFAnnotation annotation, TRectF *rect);
int PDF_SDK_API PDFAnnotation_GetString(IPDFAnnotation annotation, char *key, char *str, int size);

#ifdef __cplusplus
}
#endif
