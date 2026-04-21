import random
import time


# 1. Number guessing game
def guess_number():
    secret = random.randint(1, 100)
    attempts = 0
    print("Guess the number (1-100)")
    while True:
        guess = int(input("Your guess: "))
        attempts += 1
        if guess < secret:
            print("Too low")
        elif guess > secret:
            print("Too high")
        else:
            print(f"Correct! Attempts: {attempts}")
            break

# 2. Simple calculator
def calculator():
    a = float(input("A: "))
    b = float(input("B: "))
    op = input("(+ - * /): ")
    if op == "+": print(a + b)
    elif op == "-": print(a - b)
    elif op == "*": print(a * b)
    elif op == "/": print(a / b if b != 0 else "Error")

# 3. Password generator
def password_gen():
    chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890!@#$%"
    length = int(input("Length: "))
    pw = "".join(random.choice(chars) for _ in range(length))
    print("Password:", pw)

# 4. Typing speed test
def typing_test():
    text = "python is fast and powerful"
    print(text)
    start = time.time()
    inp = input("Type it: ")
    end = time.time()
    print("Time:", round(end - start, 2), "seconds")

# 5. Rock paper scissors
def rps():
    choices = ["rock", "paper", "scissors"]
    user = input("rock/paper/scissors: ")
    comp = random.choice(choices)
    print("Computer:", comp)
    if user == comp:
        print("Draw")
    elif (user == "rock" and comp == "scissors") or \
         (user == "paper" and comp == "rock") or \
         (user == "scissors" and comp == "paper"):
        print("You win")
    else:
        print("You lose")

# 6. FizzBuzz
def fizzbuzz():
    for i in range(1, 101):
        if i % 3 == 0 and i % 5 == 0:
            print("FizzBuzz")
        elif i % 3 == 0:
            print("Fizz")
        elif i % 5 == 0:
            print("Buzz")
        else:
            print(i)

# 7. Simple to-do list
todos = []
def todo_app():
    while True:
        print("1.Add 2.View 3.Exit")
        c = input(": ")
        if c == "1":
            todos.append(input("Task: "))
        elif c == "2":
            print(todos)
        else:
            break

# 8. Dice roller
def dice():
    print("Rolled:", random.randint(1, 6))

# 9. Even/Odd checker
def even_odd():
    n = int(input("Number: "))
    print("Even" if n % 2 == 0 else "Odd")

# 10. Basic login simulation
def login():
    user = "admin"
    pw = "1234"
    u = input("User: ")
    p = input("Pass: ")
    print("Success" if u == user and p == pw else "Fail")

# 11. Multiplication table
def table():
    n = int(input("Number: "))
    for i in range(1, 11):
        print(n, "x", i, "=", n*i)

# 12. Mini text adventure
def adventure():
    print("You are in a room. left or right?")
    c = input("Choice: ")
    if c == "left":
        print("You found treasure")
    else:
        print("You fell into a trap")

# 13. Word counter
def word_count():
    text = input("Text: ")
    print("Words:", len(text.split()))

# 14. Tkinter simple counter
import tkinter as tk
def tkinter_counter():
    root = tk.Tk()
    root.title("Counter")
    count = 0

    def inc():
        nonlocal count
        count += 1
        label.config(text=str(count))

    label = tk.Label(root, text="0", font=("Arial", 30))
    label.pack()
    btn = tk.Button(root, text="+1", command=inc)
    btn.pack()

    root.mainloop()

# 15. Guessing AI (random bot)
def ai_guess():
    num = random.randint(1, 10)
    guess = random.randint(1, 10)
    print("AI guessed", guess, "target was", num)
    print("Win" if guess == num else "Lose")

# =========================
# MENU
# =========================

def menu():
    while True:
        print("""
1 Guess Number
2 Calculator
3 Password Gen
4 Typing Test
5 RPS
6 FizzBuzz
7 Todo
8 Dice
9 Even/Odd
10 Login
11 Table
12 Adventure
13 Word Count
14 Tkinter Counter
15 AI Guess
0 Exit
""")

        c = input("Choose: ")

        if c == "1": guess_number()
        elif c == "2": calculator()
        elif c == "3": password_gen()
        elif c == "4": typing_test()
        elif c == "5": rps()
        elif c == "6": fizzbuzz()
        elif c == "7": todo_app()
        elif c == "8": dice()
        elif c == "9": even_odd()
        elif c == "10": login()
        elif c == "11": table()
        elif c == "12": adventure()
        elif c == "13": word_count()
        elif c == "14": tkinter_counter()
        elif c == "15": ai_guess()
        elif c == "0": break
        else:
            print("Invalid")

if __name__ == "__main__":
    menu()
