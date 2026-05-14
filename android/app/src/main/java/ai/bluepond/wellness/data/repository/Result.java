package ai.bluepond.wellness.data.repository;

/**
 * Generic sealed-class-style Result wrapper for async operations.
 * Represents one of three states: Loading, Success, or Error.
 */
public abstract class Result<T> {

    private Result() {}

    public boolean isLoading() { return this instanceof Loading; }
    public boolean isSuccess() { return this instanceof Success; }
    public boolean isError()   { return this instanceof Error; }

    @SuppressWarnings("unchecked")
    public T getData() {
        if (this instanceof Success) {
            return ((Success<T>) this).data;
        }
        return null;
    }

    public String getErrorMessage() {
        if (this instanceof Error) {
            return ((Error<?>) this).message;
        }
        return null;
    }

    public Exception getException() {
        if (this instanceof Error) {
            return ((Error<?>) this).exception;
        }
        return null;
    }

    // ── State subclasses ──────────────────────────────────────────────────────────

    public static final class Loading<T> extends Result<T> {
        public Loading() {}
    }

    public static final class Success<T> extends Result<T> {
        public final T data;

        public Success(T data) {
            this.data = data;
        }
    }

    public static final class Error<T> extends Result<T> {
        public final String message;
        public final Exception exception;

        public Error(String message) {
            this.message = message;
            this.exception = null;
        }

        public Error(String message, Exception exception) {
            this.message = message;
            this.exception = exception;
        }
    }

    // ── Factory methods ───────────────────────────────────────────────────────────

    public static <T> Result<T> loading() {
        return new Loading<>();
    }

    public static <T> Result<T> success(T data) {
        return new Success<>(data);
    }

    public static <T> Result<T> error(String message) {
        return new Error<>(message);
    }

    public static <T> Result<T> error(String message, Exception exception) {
        return new Error<>(message, exception);
    }
}
