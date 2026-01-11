public class Stack {
    private List<Object> items;

    public Stack() {
        this.items = new List<Object>();
    }

    public integer size() {
        return this.items.size();
    }

    public boolean isEmpty() {
        return this.items.isEmpty();
    }

    public void push(Object item) {
        this.items.add(item);
    }

    public Object pop() {
        if (!isEmpty()) {
            return this.items.remove(this.items.size() - 1);
        } else {
            throw new ListException(System.Label.error_empty_stack_pop);
        }
    }

    public Object top() {
        if (!isEmpty()) {
            return this.items.get(this.items.size() - 1);
        } else {
            throw new ListException(System.Label.error_empty_stack_top);
        }
    }

    public Object peek() {
        if (!isEmpty()) {
            return this.items.get(this.items.size() - 1);
        } else {
            return null;
        }
    }
}