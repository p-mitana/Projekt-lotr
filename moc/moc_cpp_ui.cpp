/****************************************************************************
** Meta object code from reading C++ file 'cpp_ui.h'
**
** Created by: The Qt Meta Object Compiler version 67 (Qt 5.0.2)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../src/ui/cpp_ui.h"
#include <QtCore/qbytearray.h>
#include <QtCore/qmetatype.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'cpp_ui.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 67
#error "This file was generated using the moc from 5.0.2. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
struct qt_meta_stringdata_UI_t {
    QByteArrayData data[12];
    char stringdata[123];
};
#define QT_MOC_LITERAL(idx, ofs, len) \
    Q_STATIC_BYTE_ARRAY_DATA_HEADER_INITIALIZER_WITH_OFFSET(len, \
    offsetof(qt_meta_stringdata_UI_t, stringdata) + ofs \
        - idx * sizeof(QByteArrayData) \
    )
static const qt_meta_stringdata_UI_t qt_meta_stringdata_UI = {
    {
QT_MOC_LITERAL(0, 0, 2),
QT_MOC_LITERAL(1, 3, 15),
QT_MOC_LITERAL(2, 19, 0),
QT_MOC_LITERAL(3, 20, 14),
QT_MOC_LITERAL(4, 35, 14),
QT_MOC_LITERAL(5, 50, 15),
QT_MOC_LITERAL(6, 66, 7),
QT_MOC_LITERAL(7, 74, 6),
QT_MOC_LITERAL(8, 81, 7),
QT_MOC_LITERAL(9, 89, 12),
QT_MOC_LITERAL(10, 102, 12),
QT_MOC_LITERAL(11, 115, 6)
    },
    "UI\0simulationStart\0\0simulationStop\0"
    "simulationStep\0simulationReset\0saveLog\0"
    "zoomIn\0zoomOut\0loadSettings\0saveSettings\0"
    "params\0"
};
#undef QT_MOC_LITERAL

static const uint qt_meta_data_UI[] = {

 // content:
       7,       // revision
       0,       // classname
       0,    0, // classinfo
       9,   14, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       0,       // signalCount

 // slots: name, argc, parameters, tag, flags
       1,    0,   59,    2, 0x0a,
       3,    0,   60,    2, 0x0a,
       4,    0,   61,    2, 0x0a,
       5,    0,   62,    2, 0x0a,
       6,    0,   63,    2, 0x0a,
       7,    0,   64,    2, 0x0a,
       8,    0,   65,    2, 0x0a,
       9,    0,   66,    2, 0x0a,
      10,    1,   67,    2, 0x0a,

 // slots: parameters
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void, QMetaType::QString,   11,

       0        // eod
};

void UI::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        UI *_t = static_cast<UI *>(_o);
        switch (_id) {
        case 0: _t->simulationStart(); break;
        case 1: _t->simulationStop(); break;
        case 2: _t->simulationStep(); break;
        case 3: _t->simulationReset(); break;
        case 4: _t->saveLog(); break;
        case 5: _t->zoomIn(); break;
        case 6: _t->zoomOut(); break;
        case 7: _t->loadSettings(); break;
        case 8: _t->saveSettings((*reinterpret_cast< QString(*)>(_a[1]))); break;
        default: ;
        }
    }
}

const QMetaObject UI::staticMetaObject = {
    { &QQuickView::staticMetaObject, qt_meta_stringdata_UI.data,
      qt_meta_data_UI,  qt_static_metacall, 0, 0}
};


const QMetaObject *UI::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *UI::qt_metacast(const char *_clname)
{
    if (!_clname) return 0;
    if (!strcmp(_clname, qt_meta_stringdata_UI.stringdata))
        return static_cast<void*>(const_cast< UI*>(this));
    return QQuickView::qt_metacast(_clname);
}

int UI::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QQuickView::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 9)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 9;
    } else if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 9)
            *reinterpret_cast<int*>(_a[0]) = -1;
        _id -= 9;
    }
    return _id;
}
QT_END_MOC_NAMESPACE
