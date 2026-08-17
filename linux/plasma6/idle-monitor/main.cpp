#include <KIdleTime>
#include <QCoreApplication>
#include <QGuiApplication>
#include <QTextStream>

namespace {
void printUsage()
{
    QTextStream err(stderr);
    err << "Usage: movemouse-idle-monitor --wait-idle <milliseconds> | --wait-activity\n";
}
}

int main(int argc, char **argv)
{
    QGuiApplication app(argc, argv);
    const QStringList args = app.arguments();

    if (args.contains(QStringLiteral("--wait-activity"))) {
        QObject::connect(KIdleTime::instance(), &KIdleTime::resumingFromIdle, &app, [&app]() {
            app.exit(0);
        });

        KIdleTime::instance()->catchNextResumeEvent();
        return app.exec();
    }

    const int idleIndex = args.indexOf(QStringLiteral("--wait-idle"));
    if (idleIndex >= 0 && idleIndex + 1 < args.size()) {
        bool ok = false;
        const int timeoutMs = args.at(idleIndex + 1).toInt(&ok);
        if (!ok || timeoutMs < 1) {
            printUsage();
            return 2;
        }

        QObject::connect(
            KIdleTime::instance(),
            qOverload<int, int>(&KIdleTime::timeoutReached),
            &app,
            [&app, timeoutMs](int, int reachedMs) {
                if (reachedMs == timeoutMs) {
                    app.exit(0);
                }
            });

        KIdleTime::instance()->addIdleTimeout(timeoutMs);
        return app.exec();
    }

    printUsage();
    return 2;
}
