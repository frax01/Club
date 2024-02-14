import com.google.firebase.messaging.FirebaseMessagingService;
import com.google.firebase.messaging.RemoteMessage;
import androidx.core.app.NotificationCompat;
import androidx.core.app.NotificationManagerCompat;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.os.Build;
import java.util.Random;

public class MyFirebaseMessagingService extends FirebaseMessagingService {

    @Override
public void onMessageReceived(RemoteMessage remoteMessage) {
    super.onMessageReceived(remoteMessage);

    System.out.println("From: " + remoteMessage.getFrom());
    System.out.println("Notification Message Body: " + remoteMessage.getNotification().getBody());

    // Crea un ID per la notifica
    int notificationId = new Random().nextInt();

    // Crea un canale per la notifica (richiesto per Android 8 e versioni successive)
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
        CharSequence name = "MyChannel";
        String description = "This is my channel";
        int importance = NotificationManager.IMPORTANCE_DEFAULT;
        NotificationChannel channel = new NotificationChannel("my_channel_01", name, importance);
        channel.setDescription(description);
        NotificationManager notificationManager = getSystemService(NotificationManager.class);
        notificationManager.createNotificationChannel(channel);
    }

    // Crea la notifica
    NotificationCompat.Builder builder = new NotificationCompat.Builder(this, "my_channel_01")
            //.setSmallIcon(R.drawable.cc.jpeg)
            .setContentTitle("My Notification")
            .setContentText("Hello World!")
            .setPriority(NotificationCompat.PRIORITY_DEFAULT);

    // Mostra la notifica
    NotificationManagerCompat notificationManager = NotificationManagerCompat.from(this);
    notificationManager.notify(notificationId, builder.build());
}
}