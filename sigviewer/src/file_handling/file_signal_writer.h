// file_signal_writer.h

#ifndef FILE_SIGNAL_WRITER_H
#define FILE_SIGNAL_WRITER_H

#include "file_signal_reader.h"
#include "event_manager.h"
#include "channel_manager.h"
#include "../base/signal_event.h"



class QTextStream;

namespace BioSig_
{

// abstract signal writer
class FileSignalWriter
{
public:
    typedef FileSignalReader::SignalEventVector SignalEventVector;

    virtual ~FileSignalWriter();
    virtual FileSignalWriter* clone() = 0;

    void setLogStream(QTextStream* log_stream);

    virtual QString saveEvents (QSharedPointer<EventManager>,
                                QString const& file_path) {return file_path;}

    virtual QString newSave (QSharedPointer<ChannelManager> channel_manager,
                             QSharedPointer<EventManager> event_manager,
                             QString const& file_path) {return "not implemented yet!";}

    virtual QString save(FileSignalReader& file_signal_reader,
                      SignalEventVector& event_vector,
                      const QString& file_name,
                      bool save_signals = true) = 0;

protected: 
    FileSignalWriter();

    QTextStream* log_stream_;

private:
    // not allowed
    FileSignalWriter(const FileSignalWriter&);
    const FileSignalWriter& operator=(const FileSignalWriter&);
};

} // namespace BioSig_

#endif
