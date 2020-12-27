#include <windows.h>
#include <windowsx.h>
#include <wingdi.h>
#include <time.h>

LRESULT CALLBACK WndProc(HWND, UINT, WPARAM, LPARAM);
void DrawFirstLetter(HWND hwnd);

int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance,
    PSTR lpCmdLine, int nCmdShow) {

    MSG  msg;
    WNDCLASSW wc = {0};

    wc.style = CS_HREDRAW | CS_VREDRAW;
    wc.lpszClassName = L"'N'";
    wc.hInstance     = hInstance;
    wc.hbrBackground = GetSysColorBrush(COLOR_3DFACE);
    wc.lpfnWndProc   = WndProc;
    wc.hCursor       = LoadCursor(0, IDC_ARROW);

    RegisterClassW(&wc);
    CreateWindowW(wc.lpszClassName, L"'N'",
                WS_OVERLAPPEDWINDOW | WS_VISIBLE,
                100, 100, 1000, 700, NULL, NULL, hInstance, NULL);

    while (GetMessage(&msg, NULL, 0, 0)) {
    
        TranslateMessage(&msg);
        DispatchMessage(&msg);
    }

    srand(time(NULL));

    return (int) msg.wParam;
}

LRESULT CALLBACK WndProc(HWND hwnd, UINT msg,
    WPARAM wParam, LPARAM lParam) {

    switch(msg) {

        case WM_PAINT:

            DrawFirstLetter(hwnd);
            break;

        case WM_DESTROY:

            PostQuitMessage(0);
            return 0;
    }

    return DefWindowProcW(hwnd, msg, wParam, lParam);
}

void DrawFirstLetter(HWND hwnd) {

    PAINTSTRUCT ps;
    RECT r;

    GetClientRect(hwnd, &r);

    if (r.bottom == 0) {
    
        return;
    }

    HDC hdc = BeginPaint(hwnd, &ps);

    HPEN hPen = CreatePen(PS_SOLID, 2, RGB(255, 0, 0));
    HPEN hOldPen = SelectPen(hdc, hPen);

    HBRUSH hBrush = CreateSolidBrush(RGB(0, 0, 255));
    HBRUSH hOldBrush = SelectBrush(hdc, hBrush);

    POINT vertices[] = { {100, 380}, {150, 370}, {150, 100}, 
                         {200, 50},  {250, 100}, {250, 350},
                         {750, 250}, {750, 100}, {800, 50}, 
                         {850, 100}, {850, 230}, {900, 220}, 
                         {900, 270}, {850, 280}, {850, 600}, 
                         {800, 650}, {750, 600}, {750, 300}, 
                         {250, 400}, {250, 550}, {250, 600},
                         {200, 650}, {150, 600}, {150, 420},
                         {100, 430}};

    Polygon(hdc, vertices, sizeof(vertices) / sizeof(vertices[0]));

    Pie(hdc, 150, 50, 250, 150, 250, 100, 150, 100);

    Pie(hdc, 750, 50, 850, 150, 850, 100, 750, 100);

    Pie(hdc, 150, 550, 250, 650, 150, 600, 250, 600);

    Pie(hdc, 750, 550, 850, 650, 750, 600, 850, 600);

    hPen = CreatePen(PS_SOLID, 2, RGB(0, 0, 255));
    SelectPen(hdc, hPen);

    MoveToEx(hdc, 151, 100, NULL);
    LineTo(hdc, 248, 100);

    MoveToEx(hdc, 751, 100, NULL);
    LineTo(hdc, 848, 100);

    MoveToEx(hdc, 151, 600, NULL);
    LineTo(hdc, 248, 600);

    MoveToEx(hdc, 751, 600, NULL);
    LineTo(hdc, 848, 600);

    SelectBrush(hdc, hOldBrush);
    DeleteObject(hBrush);

    SelectPen(hdc, hOldPen);
    DeleteObject(hPen);

    EndPaint(hwnd, &ps);
}