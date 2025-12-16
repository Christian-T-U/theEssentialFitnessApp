# THE ESSENTIAL FITNESS APP (TEFA)

---

## DESCRIPTION

Looking for a fitness app that motivates you to work out without the hassle of
costly subscriptions? The Essential Fitness App is designed to keep you inspired and
engaged. This app helps you track your workouts while adding a fun, gamified experience.
To encourage healthy competition, the app features a verified running leaderboard.
Additionally, it provides detailed progression charts for all exercises, helping you visualize
your progress and stay motivated. All this information will be stored securely in a database
using Firestore.

---

## ABOUT THE APP

I use cloud firebase auth for safe login and sign out.

I use firestore to hold all user data so the user can sign in anywhere

I use geolocator for tracking user position

Not super unique but does have a leaderboard which not all running apps have and a random fitness tip every time you enter the app.

Is hypothetically accessible to all users with an android device

Is submitted with an apk format

---

## HOW TO USE APP

Launch using flutter run in a perferred andriod emulator
$ flutter emulators --launch Medium_Phone_API_35

Make an account with the sign up page or use an existing account with the following credentials...
Email: ctutrup@csuchico.edu
Password: BetaTester1234

### RUNNING PAGE

Select a running distance you would like to achieve.

Hit the 'start run' button.

At anytime hit 'stop run' to update run history and stop the run.

Run to the end of the initial distance goal to potentially add a personal record for that distance.

### EXERCISE PAGE

Enter the fields.

Click the 'add exercise' to add the exercise to your routine.

To delete exercises click the delete button located on each card of the list.

### LEADERBOARD PAGE

To become ranked in a field the user must participate in a full run first.

To view rankings click on a run division (1mi, 2mi, 5mi, 10mi).

### SETTINGS PAGE

The texteditors are preloaded with your current info.

Change whatever you like and click save changes.

Delete your account with the delete button.

---

## LEFT UNFINISHED

I did plan to impliment a way to track health as that would round out a fitness app but
ran out of time. I was going to use BMI as a metric for this but I didn't prioritize this
goal at all.

I didn't impliment a way to track progress on lifts because it was too difficult to
monitor and quantify progress/no progress. I did impliment tracking for running.

On some of the input text fields I didn't check for proper inputs so it just converts to
the type I was expecting utilizing conversion methods.