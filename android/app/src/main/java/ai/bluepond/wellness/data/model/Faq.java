package ai.bluepond.wellness.data.model;

import com.google.gson.annotations.SerializedName;

public class Faq {

    @SerializedName("id")
    private String id;

    @SerializedName("question")
    private String question;

    @SerializedName("answer")
    private String answer;

    @SerializedName("category")
    private String category;

    @SerializedName("display_order")
    private int displayOrder;

    @SerializedName("is_published")
    private boolean isPublished;

    public Faq() {}

    // ── Getters ──────────────────────────────────────────────────────────────────

    public String getId() { return id; }
    public String getQuestion() { return question; }
    public String getAnswer() { return answer; }
    public String getCategory() { return category; }
    public int getDisplayOrder() { return displayOrder; }
    public boolean isPublished() { return isPublished; }

    // ── Setters ──────────────────────────────────────────────────────────────────

    public void setId(String id) { this.id = id; }
    public void setQuestion(String question) { this.question = question; }
    public void setAnswer(String answer) { this.answer = answer; }
    public void setCategory(String category) { this.category = category; }
    public void setDisplayOrder(int displayOrder) { this.displayOrder = displayOrder; }
    public void setPublished(boolean published) { isPublished = published; }
}
