#include <QtGui/QGuiApplication>
#include "qtquick2applicationviewer.h"
#include <QQmlEngine>
#include <QtQml>
#include "fileio.h"

int main(int argc, char *argv[])
{
    qmlRegisterType<FileIO, 1>("FileIO", 1, 0, "FileIO");

    QGuiApplication app(argc, argv);

    QtQuick2ApplicationViewer viewer;
    viewer.setMainQmlFile(QStringLiteral("qml/main.qml"));
    //viewer.showMaximized();
    viewer.showExpanded();

    return app.exec();
}
