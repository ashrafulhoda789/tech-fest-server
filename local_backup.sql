PRAGMA defer_foreign_keys=TRUE;
CREATE TABLE fests (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    start_date TEXT NOT NULL,
    end_date TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO "fests" ("id","title","start_date","end_date","created_at") VALUES(5,'CSE Tech Fest 2026','2026-11-01','2026-11-05','2026-10-16 18:08:32');
CREATE TABLE fest_days (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    fest_id INTEGER NOT NULL,
    day_number TEXT NOT NULL, -- 'Day 01', 'Day 02'
    date_str TEXT NOT NULL,   -- '14 October 2026'
    theme TEXT,               -- 'Understand · Engage · Inspire'
    FOREIGN KEY (fest_id) REFERENCES fests(id) ON DELETE CASCADE
);
INSERT INTO "fest_days" ("id","fest_id","day_number","date_str","theme") VALUES(34,5,'DAY 01','01 Novenmber 2026','Opening & Seminars');
INSERT INTO "fest_days" ("id","fest_id","day_number","date_str","theme") VALUES(35,5,'DAY 02','02 November 2026','Event & Seminars');
INSERT INTO "fest_days" ("id","fest_id","day_number","date_str","theme") VALUES(36,5,'DAY 03','05 November 2026','Final Round');
CREATE TABLE fest_sessions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    day_id INTEGER NOT NULL,
    start_time TEXT NOT NULL, -- '08:30'
    end_time TEXT NOT NULL,   -- '09:00'
    category TEXT,           -- 'ARRIVAL', 'SESSION 1', 'SEMINAR'
    title TEXT NOT NULL,      -- 'Inaugural Ceremony'
    description TEXT,       -- 'Chanting and ceremonial lamp lighting.'
    topics TEXT,             -- JSON Stringified Array: ["Topic 1", "Topic 2"]
    FOREIGN KEY (day_id) REFERENCES fest_days(id) ON DELETE CASCADE
);
INSERT INTO "fest_sessions" ("id","day_id","start_time","end_time","category","title","description","topics") VALUES(51,34,'10:30','11:30','OPENING','Opening Ceremony','',NULL);
INSERT INTO "fest_sessions" ("id","day_id","start_time","end_time","category","title","description","topics") VALUES(52,34,'11:30','1:30','EVENT','Programing Contest','Managed by Sohoj Coding',NULL);
INSERT INTO "fest_sessions" ("id","day_id","start_time","end_time","category","title","description","topics") VALUES(53,34,'11:30','1:00','EVENT','Idea Contest','Selection for next round',NULL);
INSERT INTO "fest_sessions" ("id","day_id","start_time","end_time","category","title","description","topics") VALUES(54,34,'11:30','1:00','EVENT','Project Proposal','Selection for next round',NULL);
INSERT INTO "fest_sessions" ("id","day_id","start_time","end_time","category","title","description","topics") VALUES(55,34,'1:30','2:30','SESSION','Speaker: Prof. Nihad Karim Chowdhury','AI Automation',NULL);
INSERT INTO "fest_sessions" ("id","day_id","start_time","end_time","category","title","description","topics") VALUES(56,35,'10:30','12:00','EVENT','SDP-2 Presentation','For 6th Semester',NULL);
INSERT INTO "fest_sessions" ("id","day_id","start_time","end_time","category","title","description","topics") VALUES(57,35,'10:30','11:30','SESSION','Speaker: Arif Istiaque','',NULL);
INSERT INTO "fest_sessions" ("id","day_id","start_time","end_time","category","title","description","topics") VALUES(58,35,'10:30','1:00','EVENT','IoT & Robotics Exhibition ','',NULL);
INSERT INTO "fest_sessions" ("id","day_id","start_time","end_time","category","title","description","topics") VALUES(59,36,'10:30','1:00','EVENT','Idea Contest ','IQAC Room',NULL);
INSERT INTO "fest_sessions" ("id","day_id","start_time","end_time","category","title","description","topics") VALUES(60,36,'10:00','1:00','EVENT','Project Exhibition ','',NULL);
INSERT INTO "fest_sessions" ("id","day_id","start_time","end_time","category","title","description","topics") VALUES(61,36,'12:00','1:00','SESSION','Speaker: Dr Abu Nowshed Chowdhury','',NULL);
INSERT INTO "fest_sessions" ("id","day_id","start_time","end_time","category","title","description","topics") VALUES(62,36,'2:00','3:00','CEREMONY','Prize Giving Ceremony','',NULL);
CREATE TABLE speakers (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    image TEXT,
    designation TEXT NOT NULL,
    country TEXT,
    description TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO "speakers" ("id","name","image","designation","country","description","created_at") VALUES(1,' Prof. Nihad Karim Chowdhury','https://cu.ac.bd/assets/image/faculty_staff_users/32_UNMYTWYLSI.jpg','Dean, Faculty of Engineering, CU',' Bangladesh','Prof. Nihad Karim Chowdhury has completed a Master’s degree in Computer Engineering from Chonbuk National University (CBNU), South Korea, and a B.Sc. in Computer Science and Engineering from Chittagong University of Engineering & Technology (CUET), Bangladesh. He is currently serving as a Professor in the Department of Computer Science & Engineering at the University of Chittagong, having previously served in the same department as an Associate Professor, Assistant Professor, and Lecturer. He also contributes over 20 years of experience in developing and validating ML models and managing high-level academic research pipelines. He brings extensive experience in Machine Learning, ensuring his research and academic contributions remain both impactful and application driven. He has an extensive publication record, including Scopus Q1 journal papers in reputed journals such as Expert Systems with Applications, Neurocomputing, and Computers in Biology and Medicine.','2026-10-16 13:58:18');
INSERT INTO "speakers" ("id","name","image","designation","country","description","created_at") VALUES(2,'Sattagit Barua','https://ping-bd.com/assets/img/education/sattagitCEO1.jpg','Head of Technology, DDN | CEO, SecureAxis Solution | Founder, Ping-BD','Bangladesh',replace('This is Sattagit Barua .CCNA, JNCIA, MTCNA, MTCRE, MTCSE  Certified.\nA Networking professional with 10+ more years of sound experience in the ISP Industry.\nExperienced Manager with a demonstrated history of working in the information technology and services industry. Skilled in Mikrotik, Cisco, Huawei, Juniper, Windows Server, Linux Server, Routing Protocols, FTTx Networks, and IP Telephony Design. Strong information technology professional with an Engineer’s Degree focused on Computer Science and Engineering (CSE).','\n',char(10)),'2026-10-16 15:27:21');
INSERT INTO "speakers" ("id","name","image","designation","country","description","created_at") VALUES(3,'Arif Istiaque','https://app.cuet.ac.bd/storage/Admins/67c31a4a75759.png','Asst. Professor, Dept. of ETE, CUET','Bangladesh','Senior Advocate Aruneshwar Gupta is a distinguished legal practitioner with extensive experience in constitutional, commercial, and law. As a senior advocate, he has appeared before the Supreme Court of India and various high courts, representing clients in matters involving governance, regulatory compliance, arbitration, and public interest litigation. Mr. Gupta has developed particular expertise in sports law, with a strong focus on the legal and regulatory framework governing sports administration in India. His work includes matters relating to the Board of Control for Cricket in India (BCCI), sports governance, disciplinary proceedings, athlete rights, and institutional reforms.','2026-10-16 15:29:01');
INSERT INTO "speakers" ("id","name","image","designation","country","description","created_at") VALUES(4,'Dr. Nurshadul Mamun','https://media.licdn.com/dms/image/v2/C4D03AQGNb9B5ERmyWg/profile-displayphoto-shrink_400_400/profile-displayphoto-shrink_400_400/0/1595532510190?e=1793836800&v=beta&t=Cz1wzomJ3oiiL615zMASX86EfHJux7mPR6YX_yfpW7E','Associate Professor, Dept. Of ETE, CUET | Ex-META, ExApple (Intern) | Researcher at UT Dallas (USA)','Bangladesh','I have recently completed PhD in Electrical Engineering at The University of Texas at Dallas. My research interests are digital signal processing, audio processing, speech processing, speech recognition, speech enhancement, noise reduction, Speaker Identification, algorithm design with machine learning, and deep learning.','2026-10-16 15:30:06');
CREATE TABLE IF NOT EXISTS "user" ("id" text not null primary key, "name" text not null, "email" text not null unique, "emailVerified" integer not null, "image" text, "createdAt" date not null, "updatedAt" date not null);
CREATE TABLE IF NOT EXISTS "session" ("id" text not null primary key, "expiresAt" date not null, "token" text not null unique, "createdAt" date not null, "updatedAt" date not null, "ipAddress" text, "userAgent" text, "userId" text not null references "user" ("id") on delete cascade);
CREATE TABLE IF NOT EXISTS "account" ("id" text not null primary key, "accountId" text not null, "providerId" text not null, "userId" text not null references "user" ("id") on delete cascade, "accessToken" text, "refreshToken" text, "idToken" text, "accessTokenExpiresAt" date, "refreshTokenExpiresAt" date, "scope" text, "password" text, "createdAt" date not null, "updatedAt" date not null);
CREATE TABLE IF NOT EXISTS "verification" ("id" text not null primary key, "identifier" text not null, "value" text not null, "expiresAt" date not null, "createdAt" date not null, "updatedAt" date not null);
CREATE TABLE admins (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    email TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL,
    name TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO "admins" ("id","email","password","name","created_at") VALUES(5,'admin@bgctechfest.com','$2b$10$nDgTPI1MaYq8ydXon1i44.RS9wwnSaqA5Yy4AOFcieinMHffZf776','Administrator','2026-10-17 07:12:19');
CREATE TABLE contacts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    first_name TEXT NOT NULL,
    last_name TEXT,
    email TEXT NOT NULL,
    phone TEXT,
    organisation TEXT,
    subject TEXT,
    message TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO "contacts" ("id","first_name","last_name","email","phone","organisation","subject","message","created_at") VALUES(1,'Ashraful Hoda','Jamshed','asrafulhoda789@gmail.com','01818299406','BGC Trust University Bangladesh','Registration','How to register as a participant','2026-10-16 19:34:41');
CREATE TABLE registrations (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    first_name TEXT NOT NULL,
    last_name TEXT,
    email TEXT NOT NULL,
    whatsapp TEXT,
    organisation TEXT,
    attending_as TEXT DEFAULT 'Participant',
    notes TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO "registrations" ("id","first_name","last_name","email","whatsapp","organisation","attending_as","notes","created_at") VALUES(1,'Ashraful','Jamshed','ashrafulhoda782904@gmail.com','01818299406','BGC Trust University Bangladesh','Contestant','I wanna participate','2026-10-16 19:59:45');
DELETE FROM sqlite_sequence;
INSERT INTO "sqlite_sequence" ("name","seq") VALUES('fests',5);
INSERT INTO "sqlite_sequence" ("name","seq") VALUES('fest_days',36);
INSERT INTO "sqlite_sequence" ("name","seq") VALUES('fest_sessions',62);
INSERT INTO "sqlite_sequence" ("name","seq") VALUES('speakers',5);
INSERT INTO "sqlite_sequence" ("name","seq") VALUES('admins',5);
INSERT INTO "sqlite_sequence" ("name","seq") VALUES('contacts',1);
INSERT INTO "sqlite_sequence" ("name","seq") VALUES('registrations',1);
CREATE INDEX "session_userId_idx" on "session" ("userId");
CREATE INDEX "account_userId_idx" on "account" ("userId");
CREATE INDEX "verification_identifier_idx" on "verification" ("identifier");