# Hotels
Acceptance criteria

Please make sure you have initial commit in GIT with metadata of empty org in Master branch. 
	Create a Dev branch from master. Create feature branch from Dev branch. 
	After that please make sure you have all stuff you've done in this new feature branch. 
	Create Pull (Merge) request from feature branch to Dev branch.
Data model (objects and relations) to store Hotels / rooms / additional services / reservations is created.
Public site is created with ability for anyone to book a room for particular period of time (if it is not booked yet).
On public site user can choose City, Check-inDate, check-out date and count of guests.
After successfull reservation - notification email is sent to user.
Create 2 recordTypes for Reservation - 'Reservation' and 'Pre-reservation'. 
	Reservations from public site should have 'Pre-reservation' recordType.
Create lightning button on Reservation to switch between 'Reservation' and 'Pre-reservation' recordTypes. 
	One should have label 'Switch to Reservation', another 'Switch to Pre-reservation'.
	After job is done - create a new Org and Deploy all work done to this new org (it will be testing / UAT org for testing purpose).
Create a community. Community should have self-registration enabled. 
	Community users can only see Reservations objects and related records (hotel, contact, room) and no other objects or fields.