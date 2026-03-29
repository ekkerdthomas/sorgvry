import 'package:cron/cron.dart';
import 'package:sorgvry_shared/database/database.dart';

void startDailySummaryCron(SorgvryDatabase db) {
  final cron = Cron();
  // 21:00 SAST = 19:00 UTC
  cron.schedule(Schedule.parse('0 19 * * *'), () async {
    // TODO: query today's summary and send email
  });
}
