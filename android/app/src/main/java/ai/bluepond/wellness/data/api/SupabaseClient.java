package ai.bluepond.wellness.data.api;

import android.content.Context;
import android.util.Log;

import java.io.IOException;
import java.util.concurrent.TimeUnit;

import ai.bluepond.wellness.BuildConfig;
import ai.bluepond.wellness.utils.SessionManager;
import okhttp3.Interceptor;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;
import okhttp3.logging.HttpLoggingInterceptor;
import retrofit2.Retrofit;
import retrofit2.converter.gson.GsonConverterFactory;

public class SupabaseClient {

    private static final String TAG = "SupabaseClient";
    private static SupabaseClient instance;

    private final Retrofit retrofit;
    private final SessionManager sessionManager;

    private SupabaseClient(Context context) {
        this.sessionManager = new SessionManager(context.getApplicationContext());

        OkHttpClient.Builder httpClientBuilder = new OkHttpClient.Builder()
                .connectTimeout(30, TimeUnit.SECONDS)
                .readTimeout(30, TimeUnit.SECONDS)
                .writeTimeout(30, TimeUnit.SECONDS);

        // Auth + API key interceptor
        httpClientBuilder.addInterceptor(new Interceptor() {
            @Override
            public Response intercept(Chain chain) throws IOException {
                Request original = chain.request();
                Request.Builder requestBuilder = original.newBuilder()
                        .header("apikey", BuildConfig.SUPABASE_ANON_KEY)
                        .header("Content-Type", "application/json");

                // Attach JWT if logged in, otherwise fall back to anon key
                String accessToken = sessionManager.getAccessToken();
                if (accessToken != null && !accessToken.isEmpty()) {
                    requestBuilder.header("Authorization", "Bearer " + accessToken);
                } else {
                    requestBuilder.header("Authorization", "Bearer " + BuildConfig.SUPABASE_ANON_KEY);
                }

                // Request single object for PATCH/POST when needed
                String method = original.method();
                if ("POST".equals(method) || "PATCH".equals(method)) {
                    requestBuilder.header("Prefer", "return=representation");
                }

                Request request = requestBuilder.build();
                return chain.proceed(request);
            }
        });

        // Logging interceptor for debug builds
        if (BuildConfig.DEBUG) {
            HttpLoggingInterceptor loggingInterceptor = new HttpLoggingInterceptor(message ->
                    Log.d(TAG, message));
            loggingInterceptor.setLevel(HttpLoggingInterceptor.Level.BODY);
            httpClientBuilder.addInterceptor(loggingInterceptor);
        }

        OkHttpClient okHttpClient = httpClientBuilder.build();

        retrofit = new Retrofit.Builder()
                .baseUrl(BuildConfig.SUPABASE_URL)
                .client(okHttpClient)
                .addConverterFactory(GsonConverterFactory.create())
                .build();
    }

    public static synchronized SupabaseClient getInstance(Context context) {
        if (instance == null) {
            instance = new SupabaseClient(context.getApplicationContext());
        }
        return instance;
    }

    public static synchronized SupabaseClient getInstance() {
        if (instance == null) {
            throw new IllegalStateException(
                    "SupabaseClient not initialized. Call getInstance(Context) first from Application.");
        }
        return instance;
    }

    public <T> T getService(Class<T> serviceClass) {
        return retrofit.create(serviceClass);
    }

    public SupabaseService getApiService() {
        return getService(SupabaseService.class);
    }
}
