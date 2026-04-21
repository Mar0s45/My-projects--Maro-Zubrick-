USE master;
GO

IF EXISTS (SELECT * FROM sys.databases WHERE name = N'Evidencia automobilov')
BEGIN
    ALTER DATABASE [Evidencia automobilov]
    SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

    DROP DATABASE [Evidencia automobilov];
END
GO

CREATE DATABASE [Evidencia automobilov];
GO

USE [Evidencia automobilov];
GO

-- Drop all tables in reverse dependency order
IF OBJECT_ID('dbo.Splatka', 'U') IS NOT NULL DROP TABLE Splatka;
IF OBJECT_ID('dbo.Uver', 'U') IS NOT NULL DROP TABLE Uver;
IF OBJECT_ID('dbo.Predaj', 'U') IS NOT NULL DROP TABLE Predaj;
IF OBJECT_ID('dbo.CenaAuta', 'U') IS NOT NULL DROP TABLE CenaAuta;
IF OBJECT_ID('dbo.HistoriaVlastnictva', 'U') IS NOT NULL DROP TABLE HistoriaVlastnictva;
IF OBJECT_ID('dbo.Kontrola', 'U') IS NOT NULL DROP TABLE Kontrola;
IF OBJECT_ID('dbo.STKStanica', 'U') IS NOT NULL DROP TABLE STKStanica;
IF OBJECT_ID('dbo.ServisnyUkon', 'U') IS NOT NULL DROP TABLE ServisnyUkon;
IF OBJECT_ID('dbo.Servis', 'U') IS NOT NULL DROP TABLE Servis;
IF OBJECT_ID('dbo.DruhServisu', 'U') IS NOT NULL DROP TABLE DruhServisu;
IF OBJECT_ID('dbo.Poistenie', 'U') IS NOT NULL DROP TABLE Poistenie;
IF OBJECT_ID('dbo.Poistovna', 'U') IS NOT NULL DROP TABLE Poistovna;
IF OBJECT_ID('dbo.Automobil', 'U') IS NOT NULL DROP TABLE Automobil;
IF OBJECT_ID('dbo.Karoseria', 'U') IS NOT NULL DROP TABLE Karoseria;
IF OBJECT_ID('dbo.Prevodovka', 'U') IS NOT NULL DROP TABLE Prevodovka;
IF OBJECT_ID('dbo.Farba', 'U') IS NOT NULL DROP TABLE Farba;
IF OBJECT_ID('dbo.Palivo', 'U') IS NOT NULL DROP TABLE Palivo;
IF OBJECT_ID('dbo.Model', 'U') IS NOT NULL DROP TABLE Model;
IF OBJECT_ID('dbo.Znacka', 'U') IS NOT NULL DROP TABLE Znacka;
IF OBJECT_ID('dbo.Majitel', 'U') IS NOT NULL DROP TABLE Majitel;
GO

CREATE TABLE Majitel(
	id INT PRIMARY KEY IDENTITY(1,1),
	meno VARCHAR(50) NOT NULL,
	priezvisko VARCHAR(50) NOT NULL,
	rodne_cislo VARCHAR(20) UNIQUE NOT NULL,
	telefon VARCHAR(20),
	email VARCHAR(100)
);
GO

CREATE TABLE Znacka(
	id INT PRIMARY KEY IDENTITY(1,1),
	nazov VARCHAR(50) UNIQUE NOT NULL
);
GO

CREATE TABLE Model(
	id INT PRIMARY KEY IDENTITY(1,1),
	znacka_id INT NOT NULL,
	nazov VARCHAR(50) NOT NULL,
	FOREIGN KEY (znacka_id) REFERENCES Znacka(id),
	UNIQUE (znacka_id, nazov)
);
GO

CREATE TABLE Palivo(
	id INT PRIMARY KEY IDENTITY(1,1),
	nazov VARCHAR(50) UNIQUE NOT NULL
);
GO

CREATE TABLE Farba(
	id INT PRIMARY KEY IDENTITY(1,1),
	nazov VARCHAR(50) UNIQUE NOT NULL
);
GO

CREATE TABLE Prevodovka(
	id INT PRIMARY KEY IDENTITY(1,1),
	nazov VARCHAR(50) UNIQUE NOT NULL
);
GO

CREATE TABLE Karoseria(
	id INT PRIMARY KEY IDENTITY(1,1),
	nazov VARCHAR(50) UNIQUE NOT NULL
);
GO

CREATE TABLE Automobil(
	id INT PRIMARY KEY IDENTITY(1,1),
	VIN VARCHAR(17) UNIQUE NOT NULL,
	model_id INT NOT NULL,
	palivo_id INT NULL,
	farba_id INT NULL,
	prevodovka_id INT NULL,
	karoseria_id INT NULL,
	rok INT CHECK (rok BETWEEN 1900 AND 2100),
	majitel_id INT NOT NULL,
	stav VARCHAR(20) NOT NULL DEFAULT 'AKTIVNE' CHECK (stav IN ('AKTIVNE','PREDANE','VYRADENE')),
	FOREIGN KEY (model_id) REFERENCES Model(id),
	FOREIGN KEY (palivo_id) REFERENCES Palivo(id),
	FOREIGN KEY (farba_id) REFERENCES Farba(id),
	FOREIGN KEY (prevodovka_id) REFERENCES Prevodovka(id),
	FOREIGN KEY (karoseria_id) REFERENCES Karoseria(id),
	FOREIGN KEY (majitel_id) REFERENCES Majitel(id)
);
GO

CREATE TABLE Poistovna(
	id INT PRIMARY KEY IDENTITY(1,1),
	nazov VARCHAR(50) UNIQUE NOT NULL
);
GO

CREATE TABLE Poistenie(
	id INT PRIMARY KEY IDENTITY(1,1),
	automobil_id INT NOT NULL,
	poistovna_id INT NOT NULL,
	cislo_zmluvy VARCHAR(50) UNIQUE NOT NULL,
	datum_zaciatku DATE NOT NULL,
	datum_konca DATE NOT NULL,
	FOREIGN KEY (automobil_id) REFERENCES Automobil(id),
	FOREIGN KEY (poistovna_id) REFERENCES Poistovna(id)
);
GO

CREATE TABLE DruhServisu(
	id INT PRIMARY KEY IDENTITY(1,1),
	nazov VARCHAR(50) UNIQUE NOT NULL
);
GO

CREATE TABLE Servis(
	id INT PRIMARY KEY IDENTITY(1,1),
	automobil_id INT NOT NULL,
	datum DATE NOT NULL,
	popis VARCHAR(255),
	cena DECIMAL(10,2) CHECK (cena >= 0),
	FOREIGN KEY (automobil_id) REFERENCES Automobil(id)
);
GO

CREATE TABLE ServisnyUkon(
	id INT PRIMARY KEY IDENTITY(1,1),
	servis_id INT NOT NULL,
	druh_servisu_id INT NOT NULL,
	hodiny DECIMAL(5,2) CHECK (hodiny >= 0),
	cena DECIMAL(10,2) CHECK (cena >= 0),
	FOREIGN KEY (servis_id) REFERENCES Servis(id),
	FOREIGN KEY (druh_servisu_id) REFERENCES DruhServisu(id)
);
GO

CREATE TABLE STKStanica(
	id INT PRIMARY KEY IDENTITY(1,1),
	nazov VARCHAR(100) NOT NULL,
	mesto VARCHAR(50) NOT NULL,
	ulica VARCHAR(100)
);
GO

CREATE TABLE Kontrola(
	id INT PRIMARY KEY IDENTITY(1,1),
	automobil_id INT NOT NULL,
	stkstanica_id INT NOT NULL,
	datum DATE NOT NULL,
	vysledok VARCHAR(20) NOT NULL CHECK (vysledok IN ('PRESIEL','NEPRESIEL')),
	FOREIGN KEY (automobil_id) REFERENCES Automobil(id),
	FOREIGN KEY (stkstanica_id) REFERENCES STKStanica(id)
);
GO

CREATE TABLE HistoriaVlastnictva(
	id INT PRIMARY KEY IDENTITY(1,1),
	automobil_id INT NOT NULL,
	stary_majitel_id INT NULL,
	novy_majitel_id INT NULL,
	datum_zmeny DATETIME NOT NULL DEFAULT GETDATE(),
	FOREIGN KEY (automobil_id) REFERENCES Automobil(id),
	FOREIGN KEY (stary_majitel_id) REFERENCES Majitel(id),
	FOREIGN KEY (novy_majitel_id) REFERENCES Majitel(id)
);
GO

CREATE TABLE CenaAuta(
	id INT PRIMARY KEY IDENTITY(1,1),
	automobil_id INT NOT NULL,
	datum_od DATE NOT NULL,
	cena DECIMAL(12,2) NOT NULL CHECK (cena >= 0),
	FOREIGN KEY (automobil_id) REFERENCES Automobil(id)
);
GO

CREATE TABLE Predaj(
	id INT PRIMARY KEY IDENTITY(1,1),
	automobil_id INT NOT NULL,
	stary_majitel_id INT NOT NULL,
	novy_majitel_id INT NOT NULL,
	datum_predaja DATETIME NOT NULL DEFAULT GETDATE(),
	cena DECIMAL(12,2) NOT NULL CHECK (cena >= 0),
	FOREIGN KEY (automobil_id) REFERENCES Automobil(id),
	FOREIGN KEY (stary_majitel_id) REFERENCES Majitel(id),
	FOREIGN KEY (novy_majitel_id) REFERENCES Majitel(id)
);
GO

CREATE TABLE Uver(
	id INT PRIMARY KEY IDENTITY(1,1),
	automobil_id INT NOT NULL,
	majitel_id INT NOT NULL,
	suma DECIMAL(12,2) NOT NULL CHECK (suma > 0),
	urok DECIMAL(5,2) NOT NULL CHECK (urok >= 0),
	datum_zaciatku DATE NOT NULL,
	datum_konca DATE NOT NULL,
	FOREIGN KEY (automobil_id) REFERENCES Automobil(id),
	FOREIGN KEY (majitel_id) REFERENCES Majitel(id)
);
GO

CREATE TABLE Splatka(
	id INT PRIMARY KEY IDENTITY(1,1),
	uver_id INT NOT NULL,
	datum_splatky DATE NOT NULL,
	suma DECIMAL(12,2) NOT NULL CHECK (suma > 0),
	uhradene BIT NOT NULL DEFAULT 0,
	FOREIGN KEY (uver_id) REFERENCES Uver(id)
);
GO

-- Majitel
INSERT INTO Majitel (meno, priezvisko, rodne_cislo, telefon, email) VALUES ('Marek', 'Novak', '800101/0001', '0900000001', 'marek.novak1@mail.sk');
INSERT INTO Majitel (meno, priezvisko, rodne_cislo, telefon, email) VALUES ('Peter', 'Kovac', '800101/0002', '0900000002', 'peter.kovac2@mail.sk');
INSERT INTO Majitel (meno, priezvisko, rodne_cislo, telefon, email) VALUES ('Juraj', 'Varga', '800101/0003', '0900000003', 'juraj.varga3@mail.sk');
INSERT INTO Majitel (meno, priezvisko, rodne_cislo, telefon, email) VALUES ('Lukas', 'Toth', '800101/0004', '0900000004', 'lukas.toth4@mail.sk');
INSERT INTO Majitel (meno, priezvisko, rodne_cislo, telefon, email) VALUES ('Tomas', 'Svec', '800101/0005', '0900000005', 'tomas.svec5@mail.sk');
INSERT INTO Majitel (meno, priezvisko, rodne_cislo, telefon, email) VALUES ('Adam', 'Bene', '800101/0006', '0900000006', 'adam.bene6@mail.sk');
INSERT INTO Majitel (meno, priezvisko, rodne_cislo, telefon, email) VALUES ('Martin', 'Horvath', '800101/0007', '0900000007', 'martin.horvath7@mail.sk');
INSERT INTO Majitel (meno, priezvisko, rodne_cislo, telefon, email) VALUES ('Jakub', 'Kral', '800101/0008', '0900000008', 'jakub.kral8@mail.sk');
INSERT INTO Majitel (meno, priezvisko, rodne_cislo, telefon, email) VALUES ('Filip', 'Pavlik', '800101/0009', '0900000009', 'filip.pavlik9@mail.sk');
INSERT INTO Majitel (meno, priezvisko, rodne_cislo, telefon, email) VALUES ('Michal', 'Kuchar', '800101/0010', '0900000010', 'michal.kuchar10@mail.sk');
INSERT INTO Majitel (meno, priezvisko, rodne_cislo, telefon, email) VALUES ('Ondrej', 'Mikula', '800101/0011', '0900000011', 'ondrej.mikula11@mail.sk');
INSERT INTO Majitel (meno, priezvisko, rodne_cislo, telefon, email) VALUES ('Samuel', 'Barto', '800101/0012', '0900000012', 'samuel.barto12@mail.sk');
INSERT INTO Majitel (meno, priezvisko, rodne_cislo, telefon, email) VALUES ('Patrik', 'Cerny', '800101/0013', '0900000013', 'patrik.cerny13@mail.sk');
INSERT INTO Majitel (meno, priezvisko, rodne_cislo, telefon, email) VALUES ('David', 'Hronec', '800101/0014', '0900000014', 'david.hronec14@mail.sk');
INSERT INTO Majitel (meno, priezvisko, rodne_cislo, telefon, email) VALUES ('Matej', 'Fiala', '800101/0015', '0900000015', 'matej.fiala15@mail.sk');
INSERT INTO Majitel (meno, priezvisko, rodne_cislo, telefon, email) VALUES ('Ivan', 'Sedlak', '800101/0016', '0900000016', 'ivan.sedlak16@mail.sk');
INSERT INTO Majitel (meno, priezvisko, rodne_cislo, telefon, email) VALUES ('Roman', 'Polak', '800101/0017', '0900000017', 'roman.polak17@mail.sk');
INSERT INTO Majitel (meno, priezvisko, rodne_cislo, telefon, email) VALUES ('Ondrej', 'Kubik', '800101/0018', '0900000018', 'ondrej.kubik18@mail.sk');
INSERT INTO Majitel (meno, priezvisko, rodne_cislo, telefon, email) VALUES ('Viktor', 'Sabol', '800101/0019', '0900000019', 'viktor.sabol19@mail.sk');
INSERT INTO Majitel (meno, priezvisko, rodne_cislo, telefon, email) VALUES ('Daniel', 'Hlinka', '800101/0020', '0900000020', 'daniel.hlinka20@mail.sk');
INSERT INTO Majitel (meno, priezvisko, rodne_cislo, telefon, email) VALUES ('Jozef', 'Mraz', '800101/0021', '0900000021', 'jozef.mraz21@mail.sk');
INSERT INTO Majitel (meno, priezvisko, rodne_cislo, telefon, email) VALUES ('Erik', 'Urban', '800101/0022', '0900000022', 'erik.urban22@mail.sk');
INSERT INTO Majitel (meno, priezvisko, rodne_cislo, telefon, email) VALUES ('Rado', 'Brezina', '800101/0023', '0900000023', 'rado.brezina23@mail.sk');
INSERT INTO Majitel (meno, priezvisko, rodne_cislo, telefon, email) VALUES ('Oliver', 'Kiss', '800101/0024', '0900000024', 'oliver.kiss24@mail.sk');
INSERT INTO Majitel (meno, priezvisko, rodne_cislo, telefon, email) VALUES ('Denis', 'Vesely', '800101/0025', '0900000025', 'denis.vesely25@mail.sk');
INSERT INTO Majitel (meno, priezvisko, rodne_cislo, telefon, email) VALUES ('Nicolas', 'Malik', '800101/0026', '0900000026', 'nicolas.malik26@mail.sk');
INSERT INTO Majitel (meno, priezvisko, rodne_cislo, telefon, email) VALUES ('Branislav', 'Lacko', '800101/0027', '0900000027', 'branislav.lacko27@mail.sk');
INSERT INTO Majitel (meno, priezvisko, rodne_cislo, telefon, email) VALUES ('Richard', 'Petrik', '800101/0028', '0900000028', 'richard.petrik28@mail.sk');
INSERT INTO Majitel (meno, priezvisko, rodne_cislo, telefon, email) VALUES ('Stano', 'Duda', '800101/0029', '0900000029', 'stano.duda29@mail.sk');
INSERT INTO Majitel (meno, priezvisko, rodne_cislo, telefon, email) VALUES ('Norbert', 'Kovacik', '800101/0030', '0900000030', 'norbert.kovacik30@mail.sk');
INSERT INTO Majitel (meno, priezvisko, rodne_cislo, telefon, email) VALUES ('Karol', 'Rybak', '800101/0031', '0900000031', 'karol.rybak31@mail.sk');
INSERT INTO Majitel (meno, priezvisko, rodne_cislo, telefon, email) VALUES ('Miroslav', 'Hanus', '800101/0032', '0900000032', 'miroslav.hanus32@mail.sk');
INSERT INTO Majitel (meno, priezvisko, rodne_cislo, telefon, email) VALUES ('Vlado', 'Hajduk', '800101/0033', '0900000033', 'vlado.hajduk33@mail.sk');
INSERT INTO Majitel (meno, priezvisko, rodne_cislo, telefon, email) VALUES ('Jaro', 'Pinta', '800101/0034', '0900000034', 'jaro.pinta34@mail.sk');
INSERT INTO Majitel (meno, priezvisko, rodne_cislo, telefon, email) VALUES ('Leo', 'Rosi', '800101/0035', '0900000035', 'leo.rosi35@mail.sk');
INSERT INTO Majitel (meno, priezvisko, rodne_cislo, telefon, email) VALUES ('Anton', 'Jurik', '800101/0036', '0900000036', 'anton.jurik36@mail.sk');
INSERT INTO Majitel (meno, priezvisko, rodne_cislo, telefon, email) VALUES ('Boris', 'Valenta', '800101/0037', '0900000037', 'boris.valenta37@mail.sk');
INSERT INTO Majitel (meno, priezvisko, rodne_cislo, telefon, email) VALUES ('Milan', 'Bielik', '800101/0038', '0900000038', 'milan.bielik38@mail.sk');
INSERT INTO Majitel (meno, priezvisko, rodne_cislo, telefon, email) VALUES ('Tibor', 'Pavuk', '800101/0039', '0900000039', 'tibor.pavuk39@mail.sk');
INSERT INTO Majitel (meno, priezvisko, rodne_cislo, telefon, email) VALUES ('Jakub', 'Sykora', '800101/0040', '0900000040', 'jakub.sykora40@mail.sk');
GO

-- Znacka
INSERT INTO Znacka (nazov) VALUES ('Skoda');
INSERT INTO Znacka (nazov) VALUES ('BMW');
INSERT INTO Znacka (nazov) VALUES ('Audi');
INSERT INTO Znacka (nazov) VALUES ('Toyota');
INSERT INTO Znacka (nazov) VALUES ('Ford');
INSERT INTO Znacka (nazov) VALUES ('Volkswagen');
INSERT INTO Znacka (nazov) VALUES ('Mercedes');
INSERT INTO Znacka (nazov) VALUES ('Kia');
INSERT INTO Znacka (nazov) VALUES ('Hyundai');
INSERT INTO Znacka (nazov) VALUES ('Renault');
INSERT INTO Znacka (nazov) VALUES ('Peugeot');
INSERT INTO Znacka (nazov) VALUES ('Opel');
INSERT INTO Znacka (nazov) VALUES ('Honda');
INSERT INTO Znacka (nazov) VALUES ('Mazda');
INSERT INTO Znacka (nazov) VALUES ('Nissan');
INSERT INTO Znacka (nazov) VALUES ('Volvo');
INSERT INTO Znacka (nazov) VALUES ('Subaru');
INSERT INTO Znacka (nazov) VALUES ('Suzuki');
INSERT INTO Znacka (nazov) VALUES ('Fiat');
INSERT INTO Znacka (nazov) VALUES ('Seat');
INSERT INTO Znacka (nazov) VALUES ('Dacia');
INSERT INTO Znacka (nazov) VALUES ('Tesla');
INSERT INTO Znacka (nazov) VALUES ('Lexus');
INSERT INTO Znacka (nazov) VALUES ('Jeep');
INSERT INTO Znacka (nazov) VALUES ('Porsche');
INSERT INTO Znacka (nazov) VALUES ('Citroen');
INSERT INTO Znacka (nazov) VALUES ('Alfa Romeo');
INSERT INTO Znacka (nazov) VALUES ('Mitsubishi');
INSERT INTO Znacka (nazov) VALUES ('Chevrolet');
INSERT INTO Znacka (nazov) VALUES ('Jaguar');
INSERT INTO Znacka (nazov) VALUES ('Land Rover');
INSERT INTO Znacka (nazov) VALUES ('Mini');
INSERT INTO Znacka (nazov) VALUES ('Cupra');
INSERT INTO Znacka (nazov) VALUES ('DS Automobiles');
INSERT INTO Znacka (nazov) VALUES ('MG');
INSERT INTO Znacka (nazov) VALUES ('Lancia');
INSERT INTO Znacka (nazov) VALUES ('BYD');
INSERT INTO Znacka (nazov) VALUES ('Polestar');
INSERT INTO Znacka (nazov) VALUES ('Smart');
INSERT INTO Znacka (nazov) VALUES ('Ram');
GO

-- Model
INSERT INTO Model (znacka_id, nazov) VALUES (1, 'Fabia');
INSERT INTO Model (znacka_id, nazov) VALUES (2, '3 Series');
INSERT INTO Model (znacka_id, nazov) VALUES (3, 'A4');
INSERT INTO Model (znacka_id, nazov) VALUES (4, 'Corolla');
INSERT INTO Model (znacka_id, nazov) VALUES (5, 'Focus');
INSERT INTO Model (znacka_id, nazov) VALUES (6, 'Golf');
INSERT INTO Model (znacka_id, nazov) VALUES (7, 'C-Class');
INSERT INTO Model (znacka_id, nazov) VALUES (8, 'Ceed');
INSERT INTO Model (znacka_id, nazov) VALUES (9, 'i30');
INSERT INTO Model (znacka_id, nazov) VALUES (10, 'Clio');
INSERT INTO Model (znacka_id, nazov) VALUES (11, '208');
INSERT INTO Model (znacka_id, nazov) VALUES (12, 'Astra');
INSERT INTO Model (znacka_id, nazov) VALUES (13, 'Civic');
INSERT INTO Model (znacka_id, nazov) VALUES (14, 'Mazda3');
INSERT INTO Model (znacka_id, nazov) VALUES (15, 'Qashqai');
INSERT INTO Model (znacka_id, nazov) VALUES (16, 'XC60');
INSERT INTO Model (znacka_id, nazov) VALUES (17, 'Forester');
INSERT INTO Model (znacka_id, nazov) VALUES (18, 'Swift');
INSERT INTO Model (znacka_id, nazov) VALUES (19, 'Punto');
INSERT INTO Model (znacka_id, nazov) VALUES (20, 'Leon');
INSERT INTO Model (znacka_id, nazov) VALUES (21, 'Duster');
INSERT INTO Model (znacka_id, nazov) VALUES (22, 'Model 3');
INSERT INTO Model (znacka_id, nazov) VALUES (23, 'RX');
INSERT INTO Model (znacka_id, nazov) VALUES (24, 'Cherokee');
INSERT INTO Model (znacka_id, nazov) VALUES (25, '911');
INSERT INTO Model (znacka_id, nazov) VALUES (26, 'C4');
INSERT INTO Model (znacka_id, nazov) VALUES (27, 'Giulia');
INSERT INTO Model (znacka_id, nazov) VALUES (28, 'Outlander');
INSERT INTO Model (znacka_id, nazov) VALUES (29, 'Cruze');
INSERT INTO Model (znacka_id, nazov) VALUES (30, 'XF');
INSERT INTO Model (znacka_id, nazov) VALUES (31, 'Range Rover');
INSERT INTO Model (znacka_id, nazov) VALUES (32, 'Cooper');
INSERT INTO Model (znacka_id, nazov) VALUES (33, 'Formentor');
INSERT INTO Model (znacka_id, nazov) VALUES (34, 'DS 7');
INSERT INTO Model (znacka_id, nazov) VALUES (35, 'ZS');
INSERT INTO Model (znacka_id, nazov) VALUES (36, 'Ypsilon');
INSERT INTO Model (znacka_id, nazov) VALUES (37, 'Seal');
INSERT INTO Model (znacka_id, nazov) VALUES (38, '2');
INSERT INTO Model (znacka_id, nazov) VALUES (39, 'Fortwo');
INSERT INTO Model (znacka_id, nazov) VALUES (40, '1500');
GO

-- Palivo
INSERT INTO Palivo (nazov) VALUES ('Benzin');
INSERT INTO Palivo (nazov) VALUES ('Nafta');
INSERT INTO Palivo (nazov) VALUES ('Elektrina');
INSERT INTO Palivo (nazov) VALUES ('Hybrid');
INSERT INTO Palivo (nazov) VALUES ('LPG');
INSERT INTO Palivo (nazov) VALUES ('CNG');
INSERT INTO Palivo (nazov) VALUES ('Vodik');
INSERT INTO Palivo (nazov) VALUES ('Plug-in Hybrid');
INSERT INTO Palivo (nazov) VALUES ('Mild Hybrid');
INSERT INTO Palivo (nazov) VALUES ('E85');
INSERT INTO Palivo (nazov) VALUES ('Biodiesel');
INSERT INTO Palivo (nazov) VALUES ('Diesel');
INSERT INTO Palivo (nazov) VALUES ('Elektro');
INSERT INTO Palivo (nazov) VALUES ('Benzin Eco');
INSERT INTO Palivo (nazov) VALUES ('Nafta Eco');
INSERT INTO Palivo (nazov) VALUES ('Benzin Sport');
INSERT INTO Palivo (nazov) VALUES ('Nafta Sport');
INSERT INTO Palivo (nazov) VALUES ('Elektro Long Range');
INSERT INTO Palivo (nazov) VALUES ('Elektro City');
INSERT INTO Palivo (nazov) VALUES ('Hybrid Eco');
INSERT INTO Palivo (nazov) VALUES ('Hybrid Sport');
INSERT INTO Palivo (nazov) VALUES ('Benzin Turbo');
INSERT INTO Palivo (nazov) VALUES ('Nafta Turbo');
INSERT INTO Palivo (nazov) VALUES ('LPG Eco');
INSERT INTO Palivo (nazov) VALUES ('CNG Eco');
INSERT INTO Palivo (nazov) VALUES ('Hydrogen Fuel');
INSERT INTO Palivo (nazov) VALUES ('Super 95');
INSERT INTO Palivo (nazov) VALUES ('Super 98');
INSERT INTO Palivo (nazov) VALUES ('Nafta Premium');
INSERT INTO Palivo (nazov) VALUES ('Benzin Natural');
INSERT INTO Palivo (nazov) VALUES ('Elektro Fast');
INSERT INTO Palivo (nazov) VALUES ('Hybrid City');
INSERT INTO Palivo (nazov) VALUES ('Benzin City');
INSERT INTO Palivo (nazov) VALUES ('Nafta City');
INSERT INTO Palivo (nazov) VALUES ('Elektro Eco');
INSERT INTO Palivo (nazov) VALUES ('Hybrid Plug-in');
INSERT INTO Palivo (nazov) VALUES ('Bivalent');
INSERT INTO Palivo (nazov) VALUES ('Ethanol');
INSERT INTO Palivo (nazov) VALUES ('Solar Assist');
INSERT INTO Palivo (nazov) VALUES ('Range Extender');
GO

-- Farba
INSERT INTO Farba (nazov) VALUES ('Biela');
INSERT INTO Farba (nazov) VALUES ('Cierna');
INSERT INTO Farba (nazov) VALUES ('Siva');
INSERT INTO Farba (nazov) VALUES ('Modra');
INSERT INTO Farba (nazov) VALUES ('Cervena');
INSERT INTO Farba (nazov) VALUES ('Strieborna');
INSERT INTO Farba (nazov) VALUES ('Zelena');
INSERT INTO Farba (nazov) VALUES ('Zlta');
INSERT INTO Farba (nazov) VALUES ('Hneda');
INSERT INTO Farba (nazov) VALUES ('Oranzova');
INSERT INTO Farba (nazov) VALUES ('Bordova');
INSERT INTO Farba (nazov) VALUES ('Fialova');
INSERT INTO Farba (nazov) VALUES ('Zlata');
INSERT INTO Farba (nazov) VALUES ('Bronzova');
INSERT INTO Farba (nazov) VALUES ('Kremova');
INSERT INTO Farba (nazov) VALUES ('Tyrkysova');
INSERT INTO Farba (nazov) VALUES ('Limetkova');
INSERT INTO Farba (nazov) VALUES ('Bledomodra');
INSERT INTO Farba (nazov) VALUES ('Tmavomodra');
INSERT INTO Farba (nazov) VALUES ('Tmavozelena');
INSERT INTO Farba (nazov) VALUES ('Svetlosiva');
INSERT INTO Farba (nazov) VALUES ('Tmavosiva');
INSERT INTO Farba (nazov) VALUES ('Bledocierna');
INSERT INTO Farba (nazov) VALUES ('Perletova');
INSERT INTO Farba (nazov) VALUES ('MatnaBiela');
INSERT INTO Farba (nazov) VALUES ('MatnaCierna');
INSERT INTO Farba (nazov) VALUES ('MatnaSiva');
INSERT INTO Farba (nazov) VALUES ('MatnaModra');
INSERT INTO Farba (nazov) VALUES ('MatnaCervena');
INSERT INTO Farba (nazov) VALUES ('MatnaZelena');
INSERT INTO Farba (nazov) VALUES ('Ruzova');
INSERT INTO Farba (nazov) VALUES ('Bledozlta');
INSERT INTO Farba (nazov) VALUES ('Bledohneda');
INSERT INTO Farba (nazov) VALUES ('Khaki');
INSERT INTO Farba (nazov) VALUES ('NebeskaModra');
INSERT INTO Farba (nazov) VALUES ('Pieskova');
INSERT INTO Farba (nazov) VALUES ('Mintova');
INSERT INTO Farba (nazov) VALUES ('Antracitova');
INSERT INTO Farba (nazov) VALUES ('Grafitova');
INSERT INTO Farba (nazov) VALUES ('Olivova');
GO

-- Prevodovka
INSERT INTO Prevodovka (nazov) VALUES ('Manual 5');
INSERT INTO Prevodovka (nazov) VALUES ('Manual 6');
INSERT INTO Prevodovka (nazov) VALUES ('Manual 7');
INSERT INTO Prevodovka (nazov) VALUES ('Automatic 6');
INSERT INTO Prevodovka (nazov) VALUES ('Automatic 8');
INSERT INTO Prevodovka (nazov) VALUES ('Automatic 9');
INSERT INTO Prevodovka (nazov) VALUES ('Automatic 10');
INSERT INTO Prevodovka (nazov) VALUES ('CVT');
INSERT INTO Prevodovka (nazov) VALUES ('DSG 6');
INSERT INTO Prevodovka (nazov) VALUES ('DSG 7');
INSERT INTO Prevodovka (nazov) VALUES ('Tiptronic');
INSERT INTO Prevodovka (nazov) VALUES ('S tronic');
INSERT INTO Prevodovka (nazov) VALUES ('Steptronic');
INSERT INTO Prevodovka (nazov) VALUES ('EAT8');
INSERT INTO Prevodovka (nazov) VALUES ('iMT');
INSERT INTO Prevodovka (nazov) VALUES ('4x4 Auto');
INSERT INTO Prevodovka (nazov) VALUES ('4x4 Manual');
INSERT INTO Prevodovka (nazov) VALUES ('Single Speed');
INSERT INTO Prevodovka (nazov) VALUES ('Dual Clutch 6');
INSERT INTO Prevodovka (nazov) VALUES ('Dual Clutch 7');
INSERT INTO Prevodovka (nazov) VALUES ('AMT');
INSERT INTO Prevodovka (nazov) VALUES ('Robotized');
INSERT INTO Prevodovka (nazov) VALUES ('Sequential');
INSERT INTO Prevodovka (nazov) VALUES ('Torque Converter');
INSERT INTO Prevodovka (nazov) VALUES ('EV Single Speed');
INSERT INTO Prevodovka (nazov) VALUES ('EV Dual Speed');
INSERT INTO Prevodovka (nazov) VALUES ('PDK');
INSERT INTO Prevodovka (nazov) VALUES ('Sport Auto');
INSERT INTO Prevodovka (nazov) VALUES ('City Auto');
INSERT INTO Prevodovka (nazov) VALUES ('Highway Auto');
INSERT INTO Prevodovka (nazov) VALUES ('Eco Manual');
INSERT INTO Prevodovka (nazov) VALUES ('Eco Auto');
INSERT INTO Prevodovka (nazov) VALUES ('8AT');
INSERT INTO Prevodovka (nazov) VALUES ('9AT');
INSERT INTO Prevodovka (nazov) VALUES ('10AT');
INSERT INTO Prevodovka (nazov) VALUES ('7MT');
INSERT INTO Prevodovka (nazov) VALUES ('6MT');
INSERT INTO Prevodovka (nazov) VALUES ('5MT');
INSERT INTO Prevodovka (nazov) VALUES ('6DCT');
INSERT INTO Prevodovka (nazov) VALUES ('7DCT');
GO

-- Karoseria
INSERT INTO Karoseria (nazov) VALUES ('Hatchback');
INSERT INTO Karoseria (nazov) VALUES ('Sedan');
INSERT INTO Karoseria (nazov) VALUES ('Combi');
INSERT INTO Karoseria (nazov) VALUES ('SUV');
INSERT INTO Karoseria (nazov) VALUES ('Coupe');
INSERT INTO Karoseria (nazov) VALUES ('Cabrio');
INSERT INTO Karoseria (nazov) VALUES ('Liftback');
INSERT INTO Karoseria (nazov) VALUES ('Fastback');
INSERT INTO Karoseria (nazov) VALUES ('MPV');
INSERT INTO Karoseria (nazov) VALUES ('Van');
INSERT INTO Karoseria (nazov) VALUES ('Pickup');
INSERT INTO Karoseria (nazov) VALUES ('Roadster');
INSERT INTO Karoseria (nazov) VALUES ('Crossover');
INSERT INTO Karoseria (nazov) VALUES ('Estate');
INSERT INTO Karoseria (nazov) VALUES ('Limousine');
INSERT INTO Karoseria (nazov) VALUES ('Station Wagon');
INSERT INTO Karoseria (nazov) VALUES ('Microcar');
INSERT INTO Karoseria (nazov) VALUES ('City Car');
INSERT INTO Karoseria (nazov) VALUES ('Offroad');
INSERT INTO Karoseria (nazov) VALUES ('Targa');
INSERT INTO Karoseria (nazov) VALUES ('Shooting Brake');
INSERT INTO Karoseria (nazov) VALUES ('Minivan');
INSERT INTO Karoseria (nazov) VALUES ('Panel Van');
INSERT INTO Karoseria (nazov) VALUES ('Utility');
INSERT INTO Karoseria (nazov) VALUES ('Bus');
INSERT INTO Karoseria (nazov) VALUES ('Lorry');
INSERT INTO Karoseria (nazov) VALUES ('Coupe SUV');
INSERT INTO Karoseria (nazov) VALUES ('Sportback');
INSERT INTO Karoseria (nazov) VALUES ('Grand Tourer');
INSERT INTO Karoseria (nazov) VALUES ('Supercar');
INSERT INTO Karoseria (nazov) VALUES ('Compact SUV');
INSERT INTO Karoseria (nazov) VALUES ('Full Size SUV');
INSERT INTO Karoseria (nazov) VALUES ('Subcompact');
INSERT INTO Karoseria (nazov) VALUES ('Mid-size SUV');
INSERT INTO Karoseria (nazov) VALUES ('Full-size Sedan');
INSERT INTO Karoseria (nazov) VALUES ('Luxury Sedan');
INSERT INTO Karoseria (nazov) VALUES ('Executive Sedan');
INSERT INTO Karoseria (nazov) VALUES ('Compact Hatchback');
INSERT INTO Karoseria (nazov) VALUES ('3-door Hatchback');
INSERT INTO Karoseria (nazov) VALUES ('5-door Hatchback');
GO

-- Automobil
INSERT INTO Automobil (VIN, model_id, palivo_id, farba_id, prevodovka_id, karoseria_id, rok, majitel_id, stav) VALUES ('STZ6S2SA500236321', 1, 1, 1, 1, 1, 2015, 1, 'AKTIVNE');
INSERT INTO Automobil (VIN, model_id, palivo_id, farba_id, prevodovka_id, karoseria_id, rok, majitel_id, stav) VALUES ('STZ6S2SA500236322', 2, 2, 2, 2, 2, 2016, 2, 'AKTIVNE');
INSERT INTO Automobil (VIN, model_id, palivo_id, farba_id, prevodovka_id, karoseria_id, rok, majitel_id, stav) VALUES ('STZ6S2SA500236323', 3, 3, 3, 3, 3, 2017, 3, 'AKTIVNE');
INSERT INTO Automobil (VIN, model_id, palivo_id, farba_id, prevodovka_id, karoseria_id, rok, majitel_id, stav) VALUES ('STZ6S2SA500236324', 4, 4, 4, 4, 4, 2018, 4, 'AKTIVNE');
INSERT INTO Automobil (VIN, model_id, palivo_id, farba_id, prevodovka_id, karoseria_id, rok, majitel_id, stav) VALUES ('STZ6S2SA500236325', 5, 1, 5, 5, 5, 2019, 5, 'AKTIVNE');
INSERT INTO Automobil (VIN, model_id, palivo_id, farba_id, prevodovka_id, karoseria_id, rok, majitel_id, stav) VALUES ('STZ6S2SA500236326', 6, 2, 6, 6, 6, 2020, 6, 'AKTIVNE');
INSERT INTO Automobil (VIN, model_id, palivo_id, farba_id, prevodovka_id, karoseria_id, rok, majitel_id, stav) VALUES ('STZ6S2SA500236327', 7, 3, 7, 7, 7, 2021, 7, 'AKTIVNE');
INSERT INTO Automobil (VIN, model_id, palivo_id, farba_id, prevodovka_id, karoseria_id, rok, majitel_id, stav) VALUES ('STZ6S2SA500236328', 8, 4, 8, 8, 8, 2022, 8, 'AKTIVNE');
INSERT INTO Automobil (VIN, model_id, palivo_id, farba_id, prevodovka_id, karoseria_id, rok, majitel_id, stav) VALUES ('STZ6S2SA500236329', 9, 1, 9, 9, 9, 2023, 9, 'AKTIVNE');
INSERT INTO Automobil (VIN, model_id, palivo_id, farba_id, prevodovka_id, karoseria_id, rok, majitel_id, stav) VALUES ('STZ6S2SA500236330', 10, 2, 10, 1, 1, 2024, 10, 'AKTIVNE');
INSERT INTO Automobil (VIN, model_id, palivo_id, farba_id, prevodovka_id, karoseria_id, rok, majitel_id, stav) VALUES ('STZ6S2SA500236331', 11, 3, 11, 2, 2, 2020, 11, 'AKTIVNE');
INSERT INTO Automobil (VIN, model_id, palivo_id, farba_id, prevodovka_id, karoseria_id, rok, majitel_id, stav) VALUES ('STZ6S2SA500236332', 12, 4, 12, 3, 3, 2019, 12, 'AKTIVNE');
INSERT INTO Automobil (VIN, model_id, palivo_id, farba_id, prevodovka_id, karoseria_id, rok, majitel_id, stav) VALUES ('STZ6S2SA500236333', 13, 1, 13, 4, 4, 2021, 13, 'AKTIVNE');
INSERT INTO Automobil (VIN, model_id, palivo_id, farba_id, prevodovka_id, karoseria_id, rok, majitel_id, stav) VALUES ('STZ6S2SA500236334', 14, 2, 14, 5, 5, 2022, 14, 'AKTIVNE');
INSERT INTO Automobil (VIN, model_id, palivo_id, farba_id, prevodovka_id, karoseria_id, rok, majitel_id, stav) VALUES ('STZ6S2SA500236335', 15, 3, 15, 6, 6, 2023, 15, 'AKTIVNE');
INSERT INTO Automobil (VIN, model_id, palivo_id, farba_id, prevodovka_id, karoseria_id, rok, majitel_id, stav) VALUES ('STZ6S2SA500236336', 16, 4, 1, 7, 7, 2024, 16, 'AKTIVNE');
INSERT INTO Automobil (VIN, model_id, palivo_id, farba_id, prevodovka_id, karoseria_id, rok, majitel_id, stav) VALUES ('STZ6S2SA500236337', 17, 1, 2, 8, 8, 2020, 17, 'AKTIVNE');
INSERT INTO Automobil (VIN, model_id, palivo_id, farba_id, prevodovka_id, karoseria_id, rok, majitel_id, stav) VALUES ('STZ6S2SA500236338', 18, 2, 3, 9, 9, 2021, 18, 'AKTIVNE');
INSERT INTO Automobil (VIN, model_id, palivo_id, farba_id, prevodovka_id, karoseria_id, rok, majitel_id, stav) VALUES ('STZ6S2SA500236339', 19, 3, 4, 1, 1, 2022, 19, 'AKTIVNE');
INSERT INTO Automobil (VIN, model_id, palivo_id, farba_id, prevodovka_id, karoseria_id, rok, majitel_id, stav) VALUES ('STZ6S2SA500236340', 20, 4, 5, 2, 2, 2023, 20, 'AKTIVNE');
INSERT INTO Automobil (VIN, model_id, palivo_id, farba_id, prevodovka_id, karoseria_id, rok, majitel_id, stav) VALUES ('STZ6S2SA500236341', 21, 1, 6, 3, 3, 2024, 21, 'AKTIVNE');
INSERT INTO Automobil (VIN, model_id, palivo_id, farba_id, prevodovka_id, karoseria_id, rok, majitel_id, stav) VALUES ('STZ6S2SA500236342', 22, 3, 7, 4, 4, 2020, 22, 'PREDANE');
INSERT INTO Automobil (VIN, model_id, palivo_id, farba_id, prevodovka_id, karoseria_id, rok, majitel_id, stav) VALUES ('STZ6S2SA500236343', 23, 2, 8, 5, 5, 2019, 23, 'AKTIVNE');
INSERT INTO Automobil (VIN, model_id, palivo_id, farba_id, prevodovka_id, karoseria_id, rok, majitel_id, stav) VALUES ('STZ6S2SA500236344', 24, 1, 9, 6, 6, 2021, 24, 'AKTIVNE');
INSERT INTO Automobil (VIN, model_id, palivo_id, farba_id, prevodovka_id, karoseria_id, rok, majitel_id, stav) VALUES ('STZ6S2SA500236345', 25, 4, 10, 7, 7, 2022, 25, 'AKTIVNE');
INSERT INTO Automobil (VIN, model_id, palivo_id, farba_id, prevodovka_id, karoseria_id, rok, majitel_id, stav) VALUES ('STZ6S2SA500236346', 26, 3, 11, 8, 8, 2023, 26, 'AKTIVNE');
INSERT INTO Automobil (VIN, model_id, palivo_id, farba_id, prevodovka_id, karoseria_id, rok, majitel_id, stav) VALUES ('STZ6S2SA500236347', 27, 2, 12, 9, 9, 2024, 27, 'AKTIVNE');
INSERT INTO Automobil (VIN, model_id, palivo_id, farba_id, prevodovka_id, karoseria_id, rok, majitel_id, stav) VALUES ('STZ6S2SA500236348', 28, 1, 13, 1, 1, 2020, 28, 'PREDANE');
INSERT INTO Automobil (VIN, model_id, palivo_id, farba_id, prevodovka_id, karoseria_id, rok, majitel_id, stav) VALUES ('STZ6S2SA500236349', 29, 4, 14, 2, 2, 2021, 29, 'AKTIVNE');
INSERT INTO Automobil (VIN, model_id, palivo_id, farba_id, prevodovka_id, karoseria_id, rok, majitel_id, stav) VALUES ('STZ6S2SA500236350', 30, 3, 15, 3, 3, 2022, 30, 'AKTIVNE');
INSERT INTO Automobil (VIN, model_id, palivo_id, farba_id, prevodovka_id, karoseria_id, rok, majitel_id, stav) VALUES ('STZ6S2SA500236351', 31, 2, 1, 4, 4, 2023, 31, 'AKTIVNE');
INSERT INTO Automobil (VIN, model_id, palivo_id, farba_id, prevodovka_id, karoseria_id, rok, majitel_id, stav) VALUES ('STZ6S2SA500236352', 32, 1, 2, 5, 5, 2024, 32, 'AKTIVNE');
INSERT INTO Automobil (VIN, model_id, palivo_id, farba_id, prevodovka_id, karoseria_id, rok, majitel_id, stav) VALUES ('STZ6S2SA500236353', 33, 4, 3, 6, 6, 2020, 33, 'AKTIVNE');
INSERT INTO Automobil (VIN, model_id, palivo_id, farba_id, prevodovka_id, karoseria_id, rok, majitel_id, stav) VALUES ('STZ6S2SA500236354', 34, 3, 4, 7, 7, 2021, 34, 'VYRADENE');
INSERT INTO Automobil (VIN, model_id, palivo_id, farba_id, prevodovka_id, karoseria_id, rok, majitel_id, stav) VALUES ('STZ6S2SA500236355', 35, 2, 5, 8, 8, 2022, 35, 'AKTIVNE');
INSERT INTO Automobil (VIN, model_id, palivo_id, farba_id, prevodovka_id, karoseria_id, rok, majitel_id, stav) VALUES ('STZ6S2SA500236356', 36, 1, 6, 9, 9, 2023, 36, 'AKTIVNE');
INSERT INTO Automobil (VIN, model_id, palivo_id, farba_id, prevodovka_id, karoseria_id, rok, majitel_id, stav) VALUES ('STZ6S2SA500236357', 37, 4, 7, 1, 1, 2024, 37, 'AKTIVNE');
INSERT INTO Automobil (VIN, model_id, palivo_id, farba_id, prevodovka_id, karoseria_id, rok, majitel_id, stav) VALUES ('STZ6S2SA500236358', 38, 3, 8, 2, 2, 2020, 38, 'AKTIVNE');
INSERT INTO Automobil (VIN, model_id, palivo_id, farba_id, prevodovka_id, karoseria_id, rok, majitel_id, stav) VALUES ('STZ6S2SA500236359', 39, 2, 9, 3, 3, 2021, 39, 'AKTIVNE');
INSERT INTO Automobil (VIN, model_id, palivo_id, farba_id, prevodovka_id, karoseria_id, rok, majitel_id, stav) VALUES ('STZ6S2SA500236360', 40, 1, 10, 4, 4, 2022, 40, 'AKTIVNE');
GO

-- Poistovna
INSERT INTO Poistovna (nazov) VALUES ('Kooperativa');
INSERT INTO Poistovna (nazov) VALUES ('Allianz');
INSERT INTO Poistovna (nazov) VALUES ('Union');
INSERT INTO Poistovna (nazov) VALUES ('Generali');
INSERT INTO Poistovna (nazov) VALUES ('Uniqa');
INSERT INTO Poistovna (nazov) VALUES ('Wustenrot');
INSERT INTO Poistovna (nazov) VALUES ('Axa');
INSERT INTO Poistovna (nazov) VALUES ('Komunalna poistovna');
INSERT INTO Poistovna (nazov) VALUES ('Ergo');
INSERT INTO Poistovna (nazov) VALUES ('Groupama');
INSERT INTO Poistovna (nazov) VALUES ('Vienna Insurance');
INSERT INTO Poistovna (nazov) VALUES ('Direct');
INSERT INTO Poistovna (nazov) VALUES ('Slavia');
INSERT INTO Poistovna (nazov) VALUES ('Colonnade');
INSERT INTO Poistovna (nazov) VALUES ('Triglav');
INSERT INTO Poistovna (nazov) VALUES ('Signal');
INSERT INTO Poistovna (nazov) VALUES ('Eterna');
INSERT INTO Poistovna (nazov) VALUES ('Orion');
INSERT INTO Poistovna (nazov) VALUES ('Astra');
INSERT INTO Poistovna (nazov) VALUES ('Omega');
INSERT INTO Poistovna (nazov) VALUES ('Delta');
INSERT INTO Poistovna (nazov) VALUES ('Beta');
INSERT INTO Poistovna (nazov) VALUES ('Alfa');
INSERT INTO Poistovna (nazov) VALUES ('Horizon');
INSERT INTO Poistovna (nazov) VALUES ('Sunrise');
INSERT INTO Poistovna (nazov) VALUES ('Domov');
INSERT INTO Poistovna (nazov) VALUES ('Protect');
INSERT INTO Poistovna (nazov) VALUES ('SafeLife');
INSERT INTO Poistovna (nazov) VALUES ('First');
INSERT INTO Poistovna (nazov) VALUES ('Premium');
INSERT INTO Poistovna (nazov) VALUES ('Global');
INSERT INTO Poistovna (nazov) VALUES ('Rapid');
INSERT INTO Poistovna (nazov) VALUES ('Titan');
INSERT INTO Poistovna (nazov) VALUES ('Nova');
INSERT INTO Poistovna (nazov) VALUES ('Vertex');
INSERT INTO Poistovna (nazov) VALUES ('Atlas');
INSERT INTO Poistovna (nazov) VALUES ('Eagle');
INSERT INTO Poistovna (nazov) VALUES ('Guard');
INSERT INTO Poistovna (nazov) VALUES ('Trust');
INSERT INTO Poistovna (nazov) VALUES ('Shield');
GO

-- Poistenie
INSERT INTO Poistenie (automobil_id, poistovna_id, cislo_zmluvy, datum_zaciatku, datum_konca) VALUES (1, 1, 'POL001', '2026-01-01', '2027-01-01');
INSERT INTO Poistenie (automobil_id, poistovna_id, cislo_zmluvy, datum_zaciatku, datum_konca) VALUES (2, 2, 'POL002', '2026-01-01', '2027-01-01');
INSERT INTO Poistenie (automobil_id, poistovna_id, cislo_zmluvy, datum_zaciatku, datum_konca) VALUES (3, 3, 'POL003', '2026-01-01', '2027-01-01');
INSERT INTO Poistenie (automobil_id, poistovna_id, cislo_zmluvy, datum_zaciatku, datum_konca) VALUES (4, 4, 'POL004', '2026-01-01', '2027-01-01');
INSERT INTO Poistenie (automobil_id, poistovna_id, cislo_zmluvy, datum_zaciatku, datum_konca) VALUES (5, 5, 'POL005', '2026-01-01', '2027-01-01');
INSERT INTO Poistenie (automobil_id, poistovna_id, cislo_zmluvy, datum_zaciatku, datum_konca) VALUES (6, 1, 'POL006', '2026-01-01', '2027-01-01');
INSERT INTO Poistenie (automobil_id, poistovna_id, cislo_zmluvy, datum_zaciatku, datum_konca) VALUES (7, 2, 'POL007', '2026-01-01', '2027-01-01');
INSERT INTO Poistenie (automobil_id, poistovna_id, cislo_zmluvy, datum_zaciatku, datum_konca) VALUES (8, 3, 'POL008', '2026-01-01', '2027-01-01');
INSERT INTO Poistenie (automobil_id, poistovna_id, cislo_zmluvy, datum_zaciatku, datum_konca) VALUES (9, 4, 'POL009', '2026-01-01', '2027-01-01');
INSERT INTO Poistenie (automobil_id, poistovna_id, cislo_zmluvy, datum_zaciatku, datum_konca) VALUES (10, 5, 'POL010', '2026-01-01', '2027-01-01');
INSERT INTO Poistenie (automobil_id, poistovna_id, cislo_zmluvy, datum_zaciatku, datum_konca) VALUES (11, 1, 'POL011', '2026-01-01', '2027-01-01');
INSERT INTO Poistenie (automobil_id, poistovna_id, cislo_zmluvy, datum_zaciatku, datum_konca) VALUES (12, 2, 'POL012', '2026-01-01', '2027-01-01');
INSERT INTO Poistenie (automobil_id, poistovna_id, cislo_zmluvy, datum_zaciatku, datum_konca) VALUES (13, 3, 'POL013', '2026-01-01', '2027-01-01');
INSERT INTO Poistenie (automobil_id, poistovna_id, cislo_zmluvy, datum_zaciatku, datum_konca) VALUES (14, 4, 'POL014', '2026-01-01', '2027-01-01');
INSERT INTO Poistenie (automobil_id, poistovna_id, cislo_zmluvy, datum_zaciatku, datum_konca) VALUES (15, 5, 'POL015', '2026-01-01', '2027-01-01');
INSERT INTO Poistenie (automobil_id, poistovna_id, cislo_zmluvy, datum_zaciatku, datum_konca) VALUES (16, 1, 'POL016', '2026-01-01', '2027-01-01');
INSERT INTO Poistenie (automobil_id, poistovna_id, cislo_zmluvy, datum_zaciatku, datum_konca) VALUES (17, 2, 'POL017', '2026-01-01', '2027-01-01');
INSERT INTO Poistenie (automobil_id, poistovna_id, cislo_zmluvy, datum_zaciatku, datum_konca) VALUES (18, 3, 'POL018', '2026-01-01', '2027-01-01');
INSERT INTO Poistenie (automobil_id, poistovna_id, cislo_zmluvy, datum_zaciatku, datum_konca) VALUES (19, 4, 'POL019', '2026-01-01', '2027-01-01');
INSERT INTO Poistenie (automobil_id, poistovna_id, cislo_zmluvy, datum_zaciatku, datum_konca) VALUES (20, 5, 'POL020', '2026-01-01', '2027-01-01');
INSERT INTO Poistenie (automobil_id, poistovna_id, cislo_zmluvy, datum_zaciatku, datum_konca) VALUES (21, 1, 'POL021', '2026-01-01', '2027-01-01');
INSERT INTO Poistenie (automobil_id, poistovna_id, cislo_zmluvy, datum_zaciatku, datum_konca) VALUES (22, 2, 'POL022', '2026-01-01', '2027-01-01');
INSERT INTO Poistenie (automobil_id, poistovna_id, cislo_zmluvy, datum_zaciatku, datum_konca) VALUES (23, 3, 'POL023', '2026-01-01', '2027-01-01');
INSERT INTO Poistenie (automobil_id, poistovna_id, cislo_zmluvy, datum_zaciatku, datum_konca) VALUES (24, 4, 'POL024', '2026-01-01', '2027-01-01');
INSERT INTO Poistenie (automobil_id, poistovna_id, cislo_zmluvy, datum_zaciatku, datum_konca) VALUES (25, 5, 'POL025', '2026-01-01', '2027-01-01');
INSERT INTO Poistenie (automobil_id, poistovna_id, cislo_zmluvy, datum_zaciatku, datum_konca) VALUES (26, 1, 'POL026', '2026-01-01', '2027-01-01');
INSERT INTO Poistenie (automobil_id, poistovna_id, cislo_zmluvy, datum_zaciatku, datum_konca) VALUES (27, 2, 'POL027', '2026-01-01', '2027-01-01');
INSERT INTO Poistenie (automobil_id, poistovna_id, cislo_zmluvy, datum_zaciatku, datum_konca) VALUES (28, 3, 'POL028', '2026-01-01', '2027-01-01');
INSERT INTO Poistenie (automobil_id, poistovna_id, cislo_zmluvy, datum_zaciatku, datum_konca) VALUES (29, 4, 'POL029', '2026-01-01', '2027-01-01');
INSERT INTO Poistenie (automobil_id, poistovna_id, cislo_zmluvy, datum_zaciatku, datum_konca) VALUES (30, 5, 'POL030', '2026-01-01', '2027-01-01');
INSERT INTO Poistenie (automobil_id, poistovna_id, cislo_zmluvy, datum_zaciatku, datum_konca) VALUES (31, 1, 'POL031', '2026-01-01', '2027-01-01');
INSERT INTO Poistenie (automobil_id, poistovna_id, cislo_zmluvy, datum_zaciatku, datum_konca) VALUES (32, 2, 'POL032', '2026-01-01', '2027-01-01');
INSERT INTO Poistenie (automobil_id, poistovna_id, cislo_zmluvy, datum_zaciatku, datum_konca) VALUES (33, 3, 'POL033', '2026-01-01', '2027-01-01');
INSERT INTO Poistenie (automobil_id, poistovna_id, cislo_zmluvy, datum_zaciatku, datum_konca) VALUES (34, 4, 'POL034', '2026-01-01', '2027-01-01');
INSERT INTO Poistenie (automobil_id, poistovna_id, cislo_zmluvy, datum_zaciatku, datum_konca) VALUES (35, 5, 'POL035', '2026-01-01', '2027-01-01');
INSERT INTO Poistenie (automobil_id, poistovna_id, cislo_zmluvy, datum_zaciatku, datum_konca) VALUES (36, 1, 'POL036', '2026-01-01', '2027-01-01');
INSERT INTO Poistenie (automobil_id, poistovna_id, cislo_zmluvy, datum_zaciatku, datum_konca) VALUES (37, 2, 'POL037', '2026-01-01', '2027-01-01');
INSERT INTO Poistenie (automobil_id, poistovna_id, cislo_zmluvy, datum_zaciatku, datum_konca) VALUES (38, 3, 'POL038', '2026-01-01', '2027-01-01');
INSERT INTO Poistenie (automobil_id, poistovna_id, cislo_zmluvy, datum_zaciatku, datum_konca) VALUES (39, 4, 'POL039', '2026-01-01', '2027-01-01');
INSERT INTO Poistenie (automobil_id, poistovna_id, cislo_zmluvy, datum_zaciatku, datum_konca) VALUES (40, 5, 'POL040', '2026-01-01', '2027-01-01');
GO

-- DruhServisu
INSERT INTO DruhServisu (nazov) VALUES ('Vymena oleja');
INSERT INTO DruhServisu (nazov) VALUES ('Vymena filtrov');
INSERT INTO DruhServisu (nazov) VALUES ('Brzdy');
INSERT INTO DruhServisu (nazov) VALUES ('Pneumatiky');
INSERT INTO DruhServisu (nazov) VALUES ('Geometria');
INSERT INTO DruhServisu (nazov) VALUES ('Diagnostika');
INSERT INTO DruhServisu (nazov) VALUES ('Klima servis');
INSERT INTO DruhServisu (nazov) VALUES ('Bateria');
INSERT INTO DruhServisu (nazov) VALUES ('Spojka');
INSERT INTO DruhServisu (nazov) VALUES ('Rozvody');
INSERT INTO DruhServisu (nazov) VALUES ('Tlmice');
INSERT INTO DruhServisu (nazov) VALUES ('Podvozok');
INSERT INTO DruhServisu (nazov) VALUES ('Vyfuk');
INSERT INTO DruhServisu (nazov) VALUES ('Elektrika');
INSERT INTO DruhServisu (nazov) VALUES ('Motor');
INSERT INTO DruhServisu (nazov) VALUES ('Prevodovka');
INSERT INTO DruhServisu (nazov) VALUES ('Chladenie');
INSERT INTO DruhServisu (nazov) VALUES ('Starter');
INSERT INTO DruhServisu (nazov) VALUES ('Alternator');
INSERT INTO DruhServisu (nazov) VALUES ('Zamky');
INSERT INTO DruhServisu (nazov) VALUES ('Okna');
INSERT INTO DruhServisu (nazov) VALUES ('Svetla');
INSERT INTO DruhServisu (nazov) VALUES ('Interier');
INSERT INTO DruhServisu (nazov) VALUES ('Exterier');
INSERT INTO DruhServisu (nazov) VALUES ('Cistenie DPF');
INSERT INTO DruhServisu (nazov) VALUES ('Turbo');
INSERT INTO DruhServisu (nazov) VALUES ('Lambda sonda');
INSERT INTO DruhServisu (nazov) VALUES ('Snimace');
INSERT INTO DruhServisu (nazov) VALUES ('Palivovy system');
INSERT INTO DruhServisu (nazov) VALUES ('Brzdova kvapalina');
INSERT INTO DruhServisu (nazov) VALUES ('Servis kolies');
INSERT INTO DruhServisu (nazov) VALUES ('Zarovnanie svetiel');
INSERT INTO DruhServisu (nazov) VALUES ('Vymena sviecok');
INSERT INTO DruhServisu (nazov) VALUES ('Vymena remena');
INSERT INTO DruhServisu (nazov) VALUES ('Vymena retaze');
INSERT INTO DruhServisu (nazov) VALUES ('Vymena chladiacej kvapaliny');
INSERT INTO DruhServisu (nazov) VALUES ('Vymena spojky');
INSERT INTO DruhServisu (nazov) VALUES ('Vymena palivoveho filtra');
INSERT INTO DruhServisu (nazov) VALUES ('Vymena kabinoveho filtra');
INSERT INTO DruhServisu (nazov) VALUES ('Vymena vzduchoveho filtra');
GO

-- STKStanica
INSERT INTO STKStanica (nazov, mesto, ulica) VALUES ('STK Stanica 1', 'Mesto 1', 'Ulica 1');
INSERT INTO STKStanica (nazov, mesto, ulica) VALUES ('STK Stanica 2', 'Mesto 2', 'Ulica 2');
INSERT INTO STKStanica (nazov, mesto, ulica) VALUES ('STK Stanica 3', 'Mesto 3', 'Ulica 3');
INSERT INTO STKStanica (nazov, mesto, ulica) VALUES ('STK Stanica 4', 'Mesto 4', 'Ulica 4');
INSERT INTO STKStanica (nazov, mesto, ulica) VALUES ('STK Stanica 5', 'Mesto 5', 'Ulica 5');
INSERT INTO STKStanica (nazov, mesto, ulica) VALUES ('STK Stanica 6', 'Mesto 6', 'Ulica 6');
INSERT INTO STKStanica (nazov, mesto, ulica) VALUES ('STK Stanica 7', 'Mesto 7', 'Ulica 7');
INSERT INTO STKStanica (nazov, mesto, ulica) VALUES ('STK Stanica 8', 'Mesto 8', 'Ulica 8');
INSERT INTO STKStanica (nazov, mesto, ulica) VALUES ('STK Stanica 9', 'Mesto 9', 'Ulica 9');
INSERT INTO STKStanica (nazov, mesto, ulica) VALUES ('STK Stanica 10', 'Mesto 10', 'Ulica 10');
INSERT INTO STKStanica (nazov, mesto, ulica) VALUES ('STK Stanica 11', 'Mesto 11', 'Ulica 11');
INSERT INTO STKStanica (nazov, mesto, ulica) VALUES ('STK Stanica 12', 'Mesto 12', 'Ulica 12');
INSERT INTO STKStanica (nazov, mesto, ulica) VALUES ('STK Stanica 13', 'Mesto 13', 'Ulica 13');
INSERT INTO STKStanica (nazov, mesto, ulica) VALUES ('STK Stanica 14', 'Mesto 14', 'Ulica 14');
INSERT INTO STKStanica (nazov, mesto, ulica) VALUES ('STK Stanica 15', 'Mesto 15', 'Ulica 15');
INSERT INTO STKStanica (nazov, mesto, ulica) VALUES ('STK Stanica 16', 'Mesto 16', 'Ulica 16');
INSERT INTO STKStanica (nazov, mesto, ulica) VALUES ('STK Stanica 17', 'Mesto 17', 'Ulica 17');
INSERT INTO STKStanica (nazov, mesto, ulica) VALUES ('STK Stanica 18', 'Mesto 18', 'Ulica 18');
INSERT INTO STKStanica (nazov, mesto, ulica) VALUES ('STK Stanica 19', 'Mesto 19', 'Ulica 19');
INSERT INTO STKStanica (nazov, mesto, ulica) VALUES ('STK Stanica 20', 'Mesto 20', 'Ulica 20');
INSERT INTO STKStanica (nazov, mesto, ulica) VALUES ('STK Stanica 21', 'Mesto 21', 'Ulica 21');
INSERT INTO STKStanica (nazov, mesto, ulica) VALUES ('STK Stanica 22', 'Mesto 22', 'Ulica 22');
INSERT INTO STKStanica (nazov, mesto, ulica) VALUES ('STK Stanica 23', 'Mesto 23', 'Ulica 23');
INSERT INTO STKStanica (nazov, mesto, ulica) VALUES ('STK Stanica 24', 'Mesto 24', 'Ulica 24');
INSERT INTO STKStanica (nazov, mesto, ulica) VALUES ('STK Stanica 25', 'Mesto 25', 'Ulica 25');
INSERT INTO STKStanica (nazov, mesto, ulica) VALUES ('STK Stanica 26', 'Mesto 26', 'Ulica 26');
INSERT INTO STKStanica (nazov, mesto, ulica) VALUES ('STK Stanica 27', 'Mesto 27', 'Ulica 27');
INSERT INTO STKStanica (nazov, mesto, ulica) VALUES ('STK Stanica 28', 'Mesto 28', 'Ulica 28');
INSERT INTO STKStanica (nazov, mesto, ulica) VALUES ('STK Stanica 29', 'Mesto 29', 'Ulica 29');
INSERT INTO STKStanica (nazov, mesto, ulica) VALUES ('STK Stanica 30', 'Mesto 30', 'Ulica 30');
INSERT INTO STKStanica (nazov, mesto, ulica) VALUES ('STK Stanica 31', 'Mesto 31', 'Ulica 31');
INSERT INTO STKStanica (nazov, mesto, ulica) VALUES ('STK Stanica 32', 'Mesto 32', 'Ulica 32');
INSERT INTO STKStanica (nazov, mesto, ulica) VALUES ('STK Stanica 33', 'Mesto 33', 'Ulica 33');
INSERT INTO STKStanica (nazov, mesto, ulica) VALUES ('STK Stanica 34', 'Mesto 34', 'Ulica 34');
INSERT INTO STKStanica (nazov, mesto, ulica) VALUES ('STK Stanica 35', 'Mesto 35', 'Ulica 35');
INSERT INTO STKStanica (nazov, mesto, ulica) VALUES ('STK Stanica 36', 'Mesto 36', 'Ulica 36');
INSERT INTO STKStanica (nazov, mesto, ulica) VALUES ('STK Stanica 37', 'Mesto 37', 'Ulica 37');
INSERT INTO STKStanica (nazov, mesto, ulica) VALUES ('STK Stanica 38', 'Mesto 38', 'Ulica 38');
INSERT INTO STKStanica (nazov, mesto, ulica) VALUES ('STK Stanica 39', 'Mesto 39', 'Ulica 39');
INSERT INTO STKStanica (nazov, mesto, ulica) VALUES ('STK Stanica 40', 'Mesto 40', 'Ulica 40');
GO
--servis
INSERT INTO DruhServisu (nazov) VALUES ('Druh servisu 1');
INSERT INTO DruhServisu (nazov) VALUES ('Druh servisu 2');
INSERT INTO DruhServisu (nazov) VALUES ('Druh servisu 3');
INSERT INTO DruhServisu (nazov) VALUES ('Druh servisu 4');
INSERT INTO DruhServisu (nazov) VALUES ('Druh servisu 5');
INSERT INTO DruhServisu (nazov) VALUES ('Druh servisu 6');
INSERT INTO DruhServisu (nazov) VALUES ('Druh servisu 7');
INSERT INTO DruhServisu (nazov) VALUES ('Druh servisu 8');
INSERT INTO DruhServisu (nazov) VALUES ('Druh servisu 9');
INSERT INTO DruhServisu (nazov) VALUES ('Druh servisu 10');
INSERT INTO DruhServisu (nazov) VALUES ('Druh servisu 11');
INSERT INTO DruhServisu (nazov) VALUES ('Druh servisu 12');
INSERT INTO DruhServisu (nazov) VALUES ('Druh servisu 13');
INSERT INTO DruhServisu (nazov) VALUES ('Druh servisu 14');
INSERT INTO DruhServisu (nazov) VALUES ('Druh servisu 15');
INSERT INTO DruhServisu (nazov) VALUES ('Druh servisu 16');
INSERT INTO DruhServisu (nazov) VALUES ('Druh servisu 17');
INSERT INTO DruhServisu (nazov) VALUES ('Druh servisu 18');
INSERT INTO DruhServisu (nazov) VALUES ('Druh servisu 19');
INSERT INTO DruhServisu (nazov) VALUES ('Druh servisu 20');
INSERT INTO DruhServisu (nazov) VALUES ('Druh servisu 21');
INSERT INTO DruhServisu (nazov) VALUES ('Druh servisu 22');
INSERT INTO DruhServisu (nazov) VALUES ('Druh servisu 23');
INSERT INTO DruhServisu (nazov) VALUES ('Druh servisu 24');
INSERT INTO DruhServisu (nazov) VALUES ('Druh servisu 25');
INSERT INTO DruhServisu (nazov) VALUES ('Druh servisu 26');
INSERT INTO DruhServisu (nazov) VALUES ('Druh servisu 27');
INSERT INTO DruhServisu (nazov) VALUES ('Druh servisu 28');
INSERT INTO DruhServisu (nazov) VALUES ('Druh servisu 29');
INSERT INTO DruhServisu (nazov) VALUES ('Druh servisu 30');
INSERT INTO DruhServisu (nazov) VALUES ('Druh servisu 31');
INSERT INTO DruhServisu (nazov) VALUES ('Druh servisu 32');
INSERT INTO DruhServisu (nazov) VALUES ('Druh servisu 33');
INSERT INTO DruhServisu (nazov) VALUES ('Druh servisu 34');
INSERT INTO DruhServisu (nazov) VALUES ('Druh servisu 35');
INSERT INTO DruhServisu (nazov) VALUES ('Druh servisu 36');
INSERT INTO DruhServisu (nazov) VALUES ('Druh servisu 37');
INSERT INTO DruhServisu (nazov) VALUES ('Druh servisu 38');
INSERT INTO DruhServisu (nazov) VALUES ('Druh servisu 39');
INSERT INTO DruhServisu (nazov) VALUES ('Druh servisu 40');

INSERT INTO Servis (automobil_id, datum, popis, cena) VALUES (1, DATEADD(DAY, 1, '2026-03-01'), 'Servisny ukon 1', 62.50);
INSERT INTO Servis (automobil_id, datum, popis, cena) VALUES (2, DATEADD(DAY, 2, '2026-03-01'), 'Servisny ukon 2', 75.00);
INSERT INTO Servis (automobil_id, datum, popis, cena) VALUES (3, DATEADD(DAY, 3, '2026-03-01'), 'Servisny ukon 3', 87.50);
INSERT INTO Servis (automobil_id, datum, popis, cena) VALUES (4, DATEADD(DAY, 4, '2026-03-01'), 'Servisny ukon 4', 100.00);
INSERT INTO Servis (automobil_id, datum, popis, cena) VALUES (5, DATEADD(DAY, 5, '2026-03-01'), 'Servisny ukon 5', 112.50);
INSERT INTO Servis (automobil_id, datum, popis, cena) VALUES (6, DATEADD(DAY, 6, '2026-03-01'), 'Servisny ukon 6', 125.00);
INSERT INTO Servis (automobil_id, datum, popis, cena) VALUES (7, DATEADD(DAY, 7, '2026-03-01'), 'Servisny ukon 7', 137.50);
INSERT INTO Servis (automobil_id, datum, popis, cena) VALUES (8, DATEADD(DAY, 8, '2026-03-01'), 'Servisny ukon 8', 150.00);
INSERT INTO Servis (automobil_id, datum, popis, cena) VALUES (9, DATEADD(DAY, 9, '2026-03-01'), 'Servisny ukon 9', 162.50);
INSERT INTO Servis (automobil_id, datum, popis, cena) VALUES (10, DATEADD(DAY, 10, '2026-03-01'), 'Servisny ukon 10', 175.00);
INSERT INTO Servis (automobil_id, datum, popis, cena) VALUES (11, DATEADD(DAY, 11, '2026-03-01'), 'Servisny ukon 11', 187.50);
INSERT INTO Servis (automobil_id, datum, popis, cena) VALUES (12, DATEADD(DAY, 12, '2026-03-01'), 'Servisny ukon 12', 200.00);
INSERT INTO Servis (automobil_id, datum, popis, cena) VALUES (13, DATEADD(DAY, 13, '2026-03-01'), 'Servisny ukon 13', 212.50);
INSERT INTO Servis (automobil_id, datum, popis, cena) VALUES (14, DATEADD(DAY, 14, '2026-03-01'), 'Servisny ukon 14', 225.00);
INSERT INTO Servis (automobil_id, datum, popis, cena) VALUES (15, DATEADD(DAY, 15, '2026-03-01'), 'Servisny ukon 15', 237.50);
INSERT INTO Servis (automobil_id, datum, popis, cena) VALUES (16, DATEADD(DAY, 16, '2026-03-01'), 'Servisny ukon 16', 250.00);
INSERT INTO Servis (automobil_id, datum, popis, cena) VALUES (17, DATEADD(DAY, 17, '2026-03-01'), 'Servisny ukon 17', 262.50);
INSERT INTO Servis (automobil_id, datum, popis, cena) VALUES (18, DATEADD(DAY, 18, '2026-03-01'), 'Servisny ukon 18', 275.00);
INSERT INTO Servis (automobil_id, datum, popis, cena) VALUES (19, DATEADD(DAY, 19, '2026-03-01'), 'Servisny ukon 19', 287.50);
INSERT INTO Servis (automobil_id, datum, popis, cena) VALUES (20, DATEADD(DAY, 20, '2026-03-01'), 'Servisny ukon 20', 300.00);
INSERT INTO Servis (automobil_id, datum, popis, cena) VALUES (21, DATEADD(DAY, 21, '2026-03-01'), 'Servisny ukon 21', 312.50);
INSERT INTO Servis (automobil_id, datum, popis, cena) VALUES (22, DATEADD(DAY, 22, '2026-03-01'), 'Servisny ukon 22', 325.00);
INSERT INTO Servis (automobil_id, datum, popis, cena) VALUES (23, DATEADD(DAY, 23, '2026-03-01'), 'Servisny ukon 23', 337.50);
INSERT INTO Servis (automobil_id, datum, popis, cena) VALUES (24, DATEADD(DAY, 24, '2026-03-01'), 'Servisny ukon 24', 350.00);
INSERT INTO Servis (automobil_id, datum, popis, cena) VALUES (25, DATEADD(DAY, 25, '2026-03-01'), 'Servisny ukon 25', 362.50);
INSERT INTO Servis (automobil_id, datum, popis, cena) VALUES (26, DATEADD(DAY, 26, '2026-03-01'), 'Servisny ukon 26', 375.00);
INSERT INTO Servis (automobil_id, datum, popis, cena) VALUES (27, DATEADD(DAY, 27, '2026-03-01'), 'Servisny ukon 27', 387.50);
INSERT INTO Servis (automobil_id, datum, popis, cena) VALUES (28, DATEADD(DAY, 28, '2026-03-01'), 'Servisny ukon 28', 400.00);
INSERT INTO Servis (automobil_id, datum, popis, cena) VALUES (29, DATEADD(DAY, 29, '2026-03-01'), 'Servisny ukon 29', 412.50);
INSERT INTO Servis (automobil_id, datum, popis, cena) VALUES (30, DATEADD(DAY, 30, '2026-03-01'), 'Servisny ukon 30', 425.00);
INSERT INTO Servis (automobil_id, datum, popis, cena) VALUES (31, DATEADD(DAY, 31, '2026-03-01'), 'Servisny ukon 31', 437.50);
INSERT INTO Servis (automobil_id, datum, popis, cena) VALUES (32, DATEADD(DAY, 32, '2026-03-01'), 'Servisny ukon 32', 450.00);
INSERT INTO Servis (automobil_id, datum, popis, cena) VALUES (33, DATEADD(DAY, 33, '2026-03-01'), 'Servisny ukon 33', 462.50);
INSERT INTO Servis (automobil_id, datum, popis, cena) VALUES (34, DATEADD(DAY, 34, '2026-03-01'), 'Servisny ukon 34', 475.00);
INSERT INTO Servis (automobil_id, datum, popis, cena) VALUES (35, DATEADD(DAY, 35, '2026-03-01'), 'Servisny ukon 35', 487.50);
INSERT INTO Servis (automobil_id, datum, popis, cena) VALUES (36, DATEADD(DAY, 36, '2026-03-01'), 'Servisny ukon 36', 500.00);
INSERT INTO Servis (automobil_id, datum, popis, cena) VALUES (37, DATEADD(DAY, 37, '2026-03-01'), 'Servisny ukon 37', 512.50);
INSERT INTO Servis (automobil_id, datum, popis, cena) VALUES (38, DATEADD(DAY, 38, '2026-03-01'), 'Servisny ukon 38', 525.00);
INSERT INTO Servis (automobil_id, datum, popis, cena) VALUES (39, DATEADD(DAY, 39, '2026-03-01'), 'Servisny ukon 39', 537.50);
INSERT INTO Servis (automobil_id, datum, popis, cena) VALUES (40, DATEADD(DAY, 40, '2026-03-01'), 'Servisny ukon 40', 550.00);

INSERT INTO ServisnyUkon (servis_id, druh_servisu_id, hodiny, cena) VALUES (1, 1, 1.00, 40.00);
INSERT INTO ServisnyUkon (servis_id, druh_servisu_id, hodiny, cena) VALUES (2, 2, 1.50, 50.00);
INSERT INTO ServisnyUkon (servis_id, druh_servisu_id, hodiny, cena) VALUES (3, 3, 2.00, 60.00);
INSERT INTO ServisnyUkon (servis_id, druh_servisu_id, hodiny, cena) VALUES (4, 4, 2.50, 70.00);
INSERT INTO ServisnyUkon (servis_id, druh_servisu_id, hodiny, cena) VALUES (5, 5, 3.00, 80.00);
INSERT INTO ServisnyUkon (servis_id, druh_servisu_id, hodiny, cena) VALUES (6, 6, 1.00, 90.00);
INSERT INTO ServisnyUkon (servis_id, druh_servisu_id, hodiny, cena) VALUES (7, 7, 1.50, 100.00);
INSERT INTO ServisnyUkon (servis_id, druh_servisu_id, hodiny, cena) VALUES (8, 8, 2.00, 110.00);
INSERT INTO ServisnyUkon (servis_id, druh_servisu_id, hodiny, cena) VALUES (9, 9, 2.50, 120.00);
INSERT INTO ServisnyUkon (servis_id, druh_servisu_id, hodiny, cena) VALUES (10, 10, 3.00, 130.00);
INSERT INTO ServisnyUkon (servis_id, druh_servisu_id, hodiny, cena) VALUES (11, 11, 1.00, 140.00);
INSERT INTO ServisnyUkon (servis_id, druh_servisu_id, hodiny, cena) VALUES (12, 12, 1.50, 150.00);
INSERT INTO ServisnyUkon (servis_id, druh_servisu_id, hodiny, cena) VALUES (13, 13, 2.00, 160.00);
INSERT INTO ServisnyUkon (servis_id, druh_servisu_id, hodiny, cena) VALUES (14, 14, 2.50, 170.00);
INSERT INTO ServisnyUkon (servis_id, druh_servisu_id, hodiny, cena) VALUES (15, 15, 3.00, 180.00);
INSERT INTO ServisnyUkon (servis_id, druh_servisu_id, hodiny, cena) VALUES (16, 16, 1.00, 190.00);
INSERT INTO ServisnyUkon (servis_id, druh_servisu_id, hodiny, cena) VALUES (17, 17, 1.50, 200.00);
INSERT INTO ServisnyUkon (servis_id, druh_servisu_id, hodiny, cena) VALUES (18, 18, 2.00, 210.00);
INSERT INTO ServisnyUkon (servis_id, druh_servisu_id, hodiny, cena) VALUES (19, 19, 2.50, 220.00);
INSERT INTO ServisnyUkon (servis_id, druh_servisu_id, hodiny, cena) VALUES (20, 20, 3.00, 230.00);
INSERT INTO ServisnyUkon (servis_id, druh_servisu_id, hodiny, cena) VALUES (21, 21, 1.00, 240.00);
INSERT INTO ServisnyUkon (servis_id, druh_servisu_id, hodiny, cena) VALUES (22, 22, 1.50, 250.00);
INSERT INTO ServisnyUkon (servis_id, druh_servisu_id, hodiny, cena) VALUES (23, 23, 2.00, 260.00);
INSERT INTO ServisnyUkon (servis_id, druh_servisu_id, hodiny, cena) VALUES (24, 24, 2.50, 270.00);
INSERT INTO ServisnyUkon (servis_id, druh_servisu_id, hodiny, cena) VALUES (25, 25, 3.00, 280.00);
INSERT INTO ServisnyUkon (servis_id, druh_servisu_id, hodiny, cena) VALUES (26, 26, 1.00, 290.00);
INSERT INTO ServisnyUkon (servis_id, druh_servisu_id, hodiny, cena) VALUES (27, 27, 1.50, 300.00);
INSERT INTO ServisnyUkon (servis_id, druh_servisu_id, hodiny, cena) VALUES (28, 28, 2.00, 310.00);
INSERT INTO ServisnyUkon (servis_id, druh_servisu_id, hodiny, cena) VALUES (29, 29, 2.50, 320.00);
INSERT INTO ServisnyUkon (servis_id, druh_servisu_id, hodiny, cena) VALUES (30, 30, 3.00, 330.00);
INSERT INTO ServisnyUkon (servis_id, druh_servisu_id, hodiny, cena) VALUES (31, 31, 1.00, 340.00);
INSERT INTO ServisnyUkon (servis_id, druh_servisu_id, hodiny, cena) VALUES (32, 32, 1.50, 350.00);
INSERT INTO ServisnyUkon (servis_id, druh_servisu_id, hodiny, cena) VALUES (33, 33, 2.00, 360.00);
INSERT INTO ServisnyUkon (servis_id, druh_servisu_id, hodiny, cena) VALUES (34, 34, 2.50, 370.00);
INSERT INTO ServisnyUkon (servis_id, druh_servisu_id, hodiny, cena) VALUES (35, 35, 3.00, 380.00);
INSERT INTO ServisnyUkon (servis_id, druh_servisu_id, hodiny, cena) VALUES (36, 36, 1.00, 390.00);
INSERT INTO ServisnyUkon (servis_id, druh_servisu_id, hodiny, cena) VALUES (37, 37, 1.50, 400.00);
INSERT INTO ServisnyUkon (servis_id, druh_servisu_id, hodiny, cena) VALUES (38, 38, 2.00, 410.00);
INSERT INTO ServisnyUkon (servis_id, druh_servisu_id, hodiny, cena) VALUES (39, 39, 2.50, 420.00);
INSERT INTO ServisnyUkon (servis_id, druh_servisu_id, hodiny, cena) VALUES (40, 40, 3.00, 430.00);

INSERT INTO STKStanica (nazov, mesto, ulica) VALUES ('STK Stanica 1', 'Mesto 1', 'Ulica 1');
INSERT INTO STKStanica (nazov, mesto, ulica) VALUES ('STK Stanica 2', 'Mesto 2', 'Ulica 2');
INSERT INTO STKStanica (nazov, mesto, ulica) VALUES ('STK Stanica 3', 'Mesto 3', 'Ulica 3');
INSERT INTO STKStanica (nazov, mesto, ulica) VALUES ('STK Stanica 4', 'Mesto 4', 'Ulica 4');
INSERT INTO STKStanica (nazov, mesto, ulica) VALUES ('STK Stanica 5', 'Mesto 5', 'Ulica 5');
INSERT INTO STKStanica (nazov, mesto, ulica) VALUES ('STK Stanica 6', 'Mesto 6', 'Ulica 6');
INSERT INTO STKStanica (nazov, mesto, ulica) VALUES ('STK Stanica 7', 'Mesto 7', 'Ulica 7');
INSERT INTO STKStanica (nazov, mesto, ulica) VALUES ('STK Stanica 8', 'Mesto 8', 'Ulica 8');
INSERT INTO STKStanica (nazov, mesto, ulica) VALUES ('STK Stanica 9', 'Mesto 9', 'Ulica 9');
INSERT INTO STKStanica (nazov, mesto, ulica) VALUES ('STK Stanica 10', 'Mesto 10', 'Ulica 10');
INSERT INTO STKStanica (nazov, mesto, ulica) VALUES ('STK Stanica 11', 'Mesto 11', 'Ulica 11');
INSERT INTO STKStanica (nazov, mesto, ulica) VALUES ('STK Stanica 12', 'Mesto 12', 'Ulica 12');
INSERT INTO STKStanica (nazov, mesto, ulica) VALUES ('STK Stanica 13', 'Mesto 13', 'Ulica 13');
INSERT INTO STKStanica (nazov, mesto, ulica) VALUES ('STK Stanica 14', 'Mesto 14', 'Ulica 14');
INSERT INTO STKStanica (nazov, mesto, ulica) VALUES ('STK Stanica 15', 'Mesto 15', 'Ulica 15');
INSERT INTO STKStanica (nazov, mesto, ulica) VALUES ('STK Stanica 16', 'Mesto 16', 'Ulica 16');
INSERT INTO STKStanica (nazov, mesto, ulica) VALUES ('STK Stanica 17', 'Mesto 17', 'Ulica 17');
INSERT INTO STKStanica (nazov, mesto, ulica) VALUES ('STK Stanica 18', 'Mesto 18', 'Ulica 18');
INSERT INTO STKStanica (nazov, mesto, ulica) VALUES ('STK Stanica 19', 'Mesto 19', 'Ulica 19');
INSERT INTO STKStanica (nazov, mesto, ulica) VALUES ('STK Stanica 20', 'Mesto 20', 'Ulica 20');
INSERT INTO STKStanica (nazov, mesto, ulica) VALUES ('STK Stanica 21', 'Mesto 21', 'Ulica 21');
INSERT INTO STKStanica (nazov, mesto, ulica) VALUES ('STK Stanica 22', 'Mesto 22', 'Ulica 22');
INSERT INTO STKStanica (nazov, mesto, ulica) VALUES ('STK Stanica 23', 'Mesto 23', 'Ulica 23');
INSERT INTO STKStanica (nazov, mesto, ulica) VALUES ('STK Stanica 24', 'Mesto 24', 'Ulica 24');
INSERT INTO STKStanica (nazov, mesto, ulica) VALUES ('STK Stanica 25', 'Mesto 25', 'Ulica 25');
INSERT INTO STKStanica (nazov, mesto, ulica) VALUES ('STK Stanica 26', 'Mesto 26', 'Ulica 26');
INSERT INTO STKStanica (nazov, mesto, ulica) VALUES ('STK Stanica 27', 'Mesto 27', 'Ulica 27');
INSERT INTO STKStanica (nazov, mesto, ulica) VALUES ('STK Stanica 28', 'Mesto 28', 'Ulica 28');
INSERT INTO STKStanica (nazov, mesto, ulica) VALUES ('STK Stanica 29', 'Mesto 29', 'Ulica 29');
INSERT INTO STKStanica (nazov, mesto, ulica) VALUES ('STK Stanica 30', 'Mesto 30', 'Ulica 30');
INSERT INTO STKStanica (nazov, mesto, ulica) VALUES ('STK Stanica 31', 'Mesto 31', 'Ulica 31');
INSERT INTO STKStanica (nazov, mesto, ulica) VALUES ('STK Stanica 32', 'Mesto 32', 'Ulica 32');
INSERT INTO STKStanica (nazov, mesto, ulica) VALUES ('STK Stanica 33', 'Mesto 33', 'Ulica 33');
INSERT INTO STKStanica (nazov, mesto, ulica) VALUES ('STK Stanica 34', 'Mesto 34', 'Ulica 34');
INSERT INTO STKStanica (nazov, mesto, ulica) VALUES ('STK Stanica 35', 'Mesto 35', 'Ulica 35');
INSERT INTO STKStanica (nazov, mesto, ulica) VALUES ('STK Stanica 36', 'Mesto 36', 'Ulica 36');
INSERT INTO STKStanica (nazov, mesto, ulica) VALUES ('STK Stanica 37', 'Mesto 37', 'Ulica 37');
INSERT INTO STKStanica (nazov, mesto, ulica) VALUES ('STK Stanica 38', 'Mesto 38', 'Ulica 38');
INSERT INTO STKStanica (nazov, mesto, ulica) VALUES ('STK Stanica 39', 'Mesto 39', 'Ulica 39');
INSERT INTO STKStanica (nazov, mesto, ulica) VALUES ('STK Stanica 40', 'Mesto 40', 'Ulica 40');

INSERT INTO Kontrola (automobil_id, stkstanica_id, datum, vysledok) VALUES (1, 1, DATEADD(DAY, 1, '2026-04-01'), 'PRESIEL');
INSERT INTO Kontrola (automobil_id, stkstanica_id, datum, vysledok) VALUES (2, 2, DATEADD(DAY, 2, '2026-04-01'), 'PRESIEL');
INSERT INTO Kontrola (automobil_id, stkstanica_id, datum, vysledok) VALUES (3, 3, DATEADD(DAY, 3, '2026-04-01'), 'PRESIEL');
INSERT INTO Kontrola (automobil_id, stkstanica_id, datum, vysledok) VALUES (4, 4, DATEADD(DAY, 4, '2026-04-01'), 'NEPRESIEL');
INSERT INTO Kontrola (automobil_id, stkstanica_id, datum, vysledok) VALUES (5, 5, DATEADD(DAY, 5, '2026-04-01'), 'PRESIEL');
INSERT INTO Kontrola (automobil_id, stkstanica_id, datum, vysledok) VALUES (6, 6, DATEADD(DAY, 6, '2026-04-01'), 'PRESIEL');
INSERT INTO Kontrola (automobil_id, stkstanica_id, datum, vysledok) VALUES (7, 7, DATEADD(DAY, 7, '2026-04-01'), 'PRESIEL');
INSERT INTO Kontrola (automobil_id, stkstanica_id, datum, vysledok) VALUES (8, 8, DATEADD(DAY, 8, '2026-04-01'), 'NEPRESIEL');
INSERT INTO Kontrola (automobil_id, stkstanica_id, datum, vysledok) VALUES (9, 9, DATEADD(DAY, 9, '2026-04-01'), 'PRESIEL');
INSERT INTO Kontrola (automobil_id, stkstanica_id, datum, vysledok) VALUES (10, 10, DATEADD(DAY, 10, '2026-04-01'), 'PRESIEL');
INSERT INTO Kontrola (automobil_id, stkstanica_id, datum, vysledok) VALUES (11, 11, DATEADD(DAY, 11, '2026-04-01'), 'PRESIEL');
INSERT INTO Kontrola (automobil_id, stkstanica_id, datum, vysledok) VALUES (12, 12, DATEADD(DAY, 12, '2026-04-01'), 'NEPRESIEL');
INSERT INTO Kontrola (automobil_id, stkstanica_id, datum, vysledok) VALUES (13, 13, DATEADD(DAY, 13, '2026-04-01'), 'PRESIEL');
INSERT INTO Kontrola (automobil_id, stkstanica_id, datum, vysledok) VALUES (14, 14, DATEADD(DAY, 14, '2026-04-01'), 'PRESIEL');
INSERT INTO Kontrola (automobil_id, stkstanica_id, datum, vysledok) VALUES (15, 15, DATEADD(DAY, 15, '2026-04-01'), 'PRESIEL');
INSERT INTO Kontrola (automobil_id, stkstanica_id, datum, vysledok) VALUES (16, 16, DATEADD(DAY, 16, '2026-04-01'), 'NEPRESIEL');
INSERT INTO Kontrola (automobil_id, stkstanica_id, datum, vysledok) VALUES (17, 17, DATEADD(DAY, 17, '2026-04-01'), 'PRESIEL');
INSERT INTO Kontrola (automobil_id, stkstanica_id, datum, vysledok) VALUES (18, 18, DATEADD(DAY, 18, '2026-04-01'), 'PRESIEL');
INSERT INTO Kontrola (automobil_id, stkstanica_id, datum, vysledok) VALUES (19, 19, DATEADD(DAY, 19, '2026-04-01'), 'PRESIEL');
INSERT INTO Kontrola (automobil_id, stkstanica_id, datum, vysledok) VALUES (20, 20, DATEADD(DAY, 20, '2026-04-01'), 'NEPRESIEL');
INSERT INTO Kontrola (automobil_id, stkstanica_id, datum, vysledok) VALUES (21, 21, DATEADD(DAY, 21, '2026-04-01'), 'PRESIEL');
INSERT INTO Kontrola (automobil_id, stkstanica_id, datum, vysledok) VALUES (22, 22, DATEADD(DAY, 22, '2026-04-01'), 'PRESIEL');
INSERT INTO Kontrola (automobil_id, stkstanica_id, datum, vysledok) VALUES (23, 23, DATEADD(DAY, 23, '2026-04-01'), 'PRESIEL');
INSERT INTO Kontrola (automobil_id, stkstanica_id, datum, vysledok) VALUES (24, 24, DATEADD(DAY, 24, '2026-04-01'), 'NEPRESIEL');
INSERT INTO Kontrola (automobil_id, stkstanica_id, datum, vysledok) VALUES (25, 25, DATEADD(DAY, 25, '2026-04-01'), 'PRESIEL');
INSERT INTO Kontrola (automobil_id, stkstanica_id, datum, vysledok) VALUES (26, 26, DATEADD(DAY, 26, '2026-04-01'), 'PRESIEL');
INSERT INTO Kontrola (automobil_id, stkstanica_id, datum, vysledok) VALUES (27, 27, DATEADD(DAY, 27, '2026-04-01'), 'PRESIEL');
INSERT INTO Kontrola (automobil_id, stkstanica_id, datum, vysledok) VALUES (28, 28, DATEADD(DAY, 28, '2026-04-01'), 'NEPRESIEL');
INSERT INTO Kontrola (automobil_id, stkstanica_id, datum, vysledok) VALUES (29, 29, DATEADD(DAY, 29, '2026-04-01'), 'PRESIEL');
INSERT INTO Kontrola (automobil_id, stkstanica_id, datum, vysledok) VALUES (30, 30, DATEADD(DAY, 30, '2026-04-01'), 'PRESIEL');
INSERT INTO Kontrola (automobil_id, stkstanica_id, datum, vysledok) VALUES (31, 31, DATEADD(DAY, 31, '2026-04-01'), 'PRESIEL');
INSERT INTO Kontrola (automobil_id, stkstanica_id, datum, vysledok) VALUES (32, 32, DATEADD(DAY, 32, '2026-04-01'), 'NEPRESIEL');
INSERT INTO Kontrola (automobil_id, stkstanica_id, datum, vysledok) VALUES (33, 33, DATEADD(DAY, 33, '2026-04-01'), 'PRESIEL');
INSERT INTO Kontrola (automobil_id, stkstanica_id, datum, vysledok) VALUES (34, 34, DATEADD(DAY, 34, '2026-04-01'), 'PRESIEL');
INSERT INTO Kontrola (automobil_id, stkstanica_id, datum, vysledok) VALUES (35, 35, DATEADD(DAY, 35, '2026-04-01'), 'PRESIEL');
INSERT INTO Kontrola (automobil_id, stkstanica_id, datum, vysledok) VALUES (36, 36, DATEADD(DAY, 36, '2026-04-01'), 'NEPRESIEL');
INSERT INTO Kontrola (automobil_id, stkstanica_id, datum, vysledok) VALUES (37, 37, DATEADD(DAY, 37, '2026-04-01'), 'PRESIEL');
INSERT INTO Kontrola (automobil_id, stkstanica_id, datum, vysledok) VALUES (38, 38, DATEADD(DAY, 38, '2026-04-01'), 'PRESIEL');
INSERT INTO Kontrola (automobil_id, stkstanica_id, datum, vysledok) VALUES (39, 39, DATEADD(DAY, 39, '2026-04-01'), 'PRESIEL');
INSERT INTO Kontrola (automobil_id, stkstanica_id, datum, vysledok) VALUES (40, 40, DATEADD(DAY, 40, '2026-04-01'), 'NEPRESIEL');

INSERT INTO HistoriaVlastnictva (automobil_id, stary_majitel_id, novy_majitel_id, datum_zmeny) VALUES (1, 1, 2, DATEADD(DAY, 1, '2026-05-01'));
INSERT INTO HistoriaVlastnictva (automobil_id, stary_majitel_id, novy_majitel_id, datum_zmeny) VALUES (2, 2, 3, DATEADD(DAY, 2, '2026-05-01'));
INSERT INTO HistoriaVlastnictva (automobil_id, stary_majitel_id, novy_majitel_id, datum_zmeny) VALUES (3, 3, 4, DATEADD(DAY, 3, '2026-05-01'));
INSERT INTO HistoriaVlastnictva (automobil_id, stary_majitel_id, novy_majitel_id, datum_zmeny) VALUES (4, 4, 5, DATEADD(DAY, 4, '2026-05-01'));
INSERT INTO HistoriaVlastnictva (automobil_id, stary_majitel_id, novy_majitel_id, datum_zmeny) VALUES (5, 5, 6, DATEADD(DAY, 5, '2026-05-01'));
INSERT INTO HistoriaVlastnictva (automobil_id, stary_majitel_id, novy_majitel_id, datum_zmeny) VALUES (6, 6, 7, DATEADD(DAY, 6, '2026-05-01'));
INSERT INTO HistoriaVlastnictva (automobil_id, stary_majitel_id, novy_majitel_id, datum_zmeny) VALUES (7, 7, 8, DATEADD(DAY, 7, '2026-05-01'));
INSERT INTO HistoriaVlastnictva (automobil_id, stary_majitel_id, novy_majitel_id, datum_zmeny) VALUES (8, 8, 9, DATEADD(DAY, 8, '2026-05-01'));
INSERT INTO HistoriaVlastnictva (automobil_id, stary_majitel_id, novy_majitel_id, datum_zmeny) VALUES (9, 9, 10, DATEADD(DAY, 9, '2026-05-01'));
INSERT INTO HistoriaVlastnictva (automobil_id, stary_majitel_id, novy_majitel_id, datum_zmeny) VALUES (10, 10, 11, DATEADD(DAY, 10, '2026-05-01'));
INSERT INTO HistoriaVlastnictva (automobil_id, stary_majitel_id, novy_majitel_id, datum_zmeny) VALUES (11, 11, 12, DATEADD(DAY, 11, '2026-05-01'));
INSERT INTO HistoriaVlastnictva (automobil_id, stary_majitel_id, novy_majitel_id, datum_zmeny) VALUES (12, 12, 13, DATEADD(DAY, 12, '2026-05-01'));
INSERT INTO HistoriaVlastnictva (automobil_id, stary_majitel_id, novy_majitel_id, datum_zmeny) VALUES (13, 13, 14, DATEADD(DAY, 13, '2026-05-01'));
INSERT INTO HistoriaVlastnictva (automobil_id, stary_majitel_id, novy_majitel_id, datum_zmeny) VALUES (14, 14, 15, DATEADD(DAY, 14, '2026-05-01'));
INSERT INTO HistoriaVlastnictva (automobil_id, stary_majitel_id, novy_majitel_id, datum_zmeny) VALUES (15, 15, 16, DATEADD(DAY, 15, '2026-05-01'));
INSERT INTO HistoriaVlastnictva (automobil_id, stary_majitel_id, novy_majitel_id, datum_zmeny) VALUES (16, 16, 17, DATEADD(DAY, 16, '2026-05-01'));
INSERT INTO HistoriaVlastnictva (automobil_id, stary_majitel_id, novy_majitel_id, datum_zmeny) VALUES (17, 17, 18, DATEADD(DAY, 17, '2026-05-01'));
INSERT INTO HistoriaVlastnictva (automobil_id, stary_majitel_id, novy_majitel_id, datum_zmeny) VALUES (18, 18, 19, DATEADD(DAY, 18, '2026-05-01'));
INSERT INTO HistoriaVlastnictva (automobil_id, stary_majitel_id, novy_majitel_id, datum_zmeny) VALUES (19, 19, 20, DATEADD(DAY, 19, '2026-05-01'));
INSERT INTO HistoriaVlastnictva (automobil_id, stary_majitel_id, novy_majitel_id, datum_zmeny) VALUES (20, 20, 21, DATEADD(DAY, 20, '2026-05-01'));
INSERT INTO HistoriaVlastnictva (automobil_id, stary_majitel_id, novy_majitel_id, datum_zmeny) VALUES (21, 21, 22, DATEADD(DAY, 21, '2026-05-01'));
INSERT INTO HistoriaVlastnictva (automobil_id, stary_majitel_id, novy_majitel_id, datum_zmeny) VALUES (22, 22, 23, DATEADD(DAY, 22, '2026-05-01'));
INSERT INTO HistoriaVlastnictva (automobil_id, stary_majitel_id, novy_majitel_id, datum_zmeny) VALUES (23, 23, 24, DATEADD(DAY, 23, '2026-05-01'));
INSERT INTO HistoriaVlastnictva (automobil_id, stary_majitel_id, novy_majitel_id, datum_zmeny) VALUES (24, 24, 25, DATEADD(DAY, 24, '2026-05-01'));
INSERT INTO HistoriaVlastnictva (automobil_id, stary_majitel_id, novy_majitel_id, datum_zmeny) VALUES (25, 25, 26, DATEADD(DAY, 25, '2026-05-01'));
INSERT INTO HistoriaVlastnictva (automobil_id, stary_majitel_id, novy_majitel_id, datum_zmeny) VALUES (26, 26, 27, DATEADD(DAY, 26, '2026-05-01'));
INSERT INTO HistoriaVlastnictva (automobil_id, stary_majitel_id, novy_majitel_id, datum_zmeny) VALUES (27, 27, 28, DATEADD(DAY, 27, '2026-05-01'));
INSERT INTO HistoriaVlastnictva (automobil_id, stary_majitel_id, novy_majitel_id, datum_zmeny) VALUES (28, 28, 29, DATEADD(DAY, 28, '2026-05-01'));
INSERT INTO HistoriaVlastnictva (automobil_id, stary_majitel_id, novy_majitel_id, datum_zmeny) VALUES (29, 29, 30, DATEADD(DAY, 29, '2026-05-01'));
INSERT INTO HistoriaVlastnictva (automobil_id, stary_majitel_id, novy_majitel_id, datum_zmeny) VALUES (30, 30, 31, DATEADD(DAY, 30, '2026-05-01'));
INSERT INTO HistoriaVlastnictva (automobil_id, stary_majitel_id, novy_majitel_id, datum_zmeny) VALUES (31, 31, 32, DATEADD(DAY, 31, '2026-05-01'));
INSERT INTO HistoriaVlastnictva (automobil_id, stary_majitel_id, novy_majitel_id, datum_zmeny) VALUES (32, 32, 33, DATEADD(DAY, 32, '2026-05-01'));
INSERT INTO HistoriaVlastnictva (automobil_id, stary_majitel_id, novy_majitel_id, datum_zmeny) VALUES (33, 33, 34, DATEADD(DAY, 33, '2026-05-01'));
INSERT INTO HistoriaVlastnictva (automobil_id, stary_majitel_id, novy_majitel_id, datum_zmeny) VALUES (34, 34, 35, DATEADD(DAY, 34, '2026-05-01'));
INSERT INTO HistoriaVlastnictva (automobil_id, stary_majitel_id, novy_majitel_id, datum_zmeny) VALUES (35, 35, 36, DATEADD(DAY, 35, '2026-05-01'));
INSERT INTO HistoriaVlastnictva (automobil_id, stary_majitel_id, novy_majitel_id, datum_zmeny) VALUES (36, 36, 37, DATEADD(DAY, 36, '2026-05-01'));
INSERT INTO HistoriaVlastnictva (automobil_id, stary_majitel_id, novy_majitel_id, datum_zmeny) VALUES (37, 37, 38, DATEADD(DAY, 37, '2026-05-01'));
INSERT INTO HistoriaVlastnictva (automobil_id, stary_majitel_id, novy_majitel_id, datum_zmeny) VALUES (38, 38, 39, DATEADD(DAY, 38, '2026-05-01'));
INSERT INTO HistoriaVlastnictva (automobil_id, stary_majitel_id, novy_majitel_id, datum_zmeny) VALUES (39, 39, 40, DATEADD(DAY, 39, '2026-05-01'));
INSERT INTO HistoriaVlastnictva (automobil_id, stary_majitel_id, novy_majitel_id, datum_zmeny) VALUES (40, 40, 1, DATEADD(DAY, 40, '2026-05-01'));

INSERT INTO CenaAuta (automobil_id, datum_od, cena) VALUES (1, DATEADD(DAY, 1, '2026-01-01'), 5750.00);
INSERT INTO CenaAuta (automobil_id, datum_od, cena) VALUES (2, DATEADD(DAY, 2, '2026-01-01'), 6500.00);
INSERT INTO CenaAuta (automobil_id, datum_od, cena) VALUES (3, DATEADD(DAY, 3, '2026-01-01'), 7250.00);
INSERT INTO CenaAuta (automobil_id, datum_od, cena) VALUES (4, DATEADD(DAY, 4, '2026-01-01'), 8000.00);
INSERT INTO CenaAuta (automobil_id, datum_od, cena) VALUES (5, DATEADD(DAY, 5, '2026-01-01'), 8750.00);
INSERT INTO CenaAuta (automobil_id, datum_od, cena) VALUES (6, DATEADD(DAY, 6, '2026-01-01'), 9500.00);
INSERT INTO CenaAuta (automobil_id, datum_od, cena) VALUES (7, DATEADD(DAY, 7, '2026-01-01'), 10250.00);
INSERT INTO CenaAuta (automobil_id, datum_od, cena) VALUES (8, DATEADD(DAY, 8, '2026-01-01'), 11000.00);
INSERT INTO CenaAuta (automobil_id, datum_od, cena) VALUES (9, DATEADD(DAY, 9, '2026-01-01'), 11750.00);
INSERT INTO CenaAuta (automobil_id, datum_od, cena) VALUES (10, DATEADD(DAY, 10, '2026-01-01'), 12500.00);
INSERT INTO CenaAuta (automobil_id, datum_od, cena) VALUES (11, DATEADD(DAY, 11, '2026-01-01'), 13250.00);
INSERT INTO CenaAuta (automobil_id, datum_od, cena) VALUES (12, DATEADD(DAY, 12, '2026-01-01'), 14000.00);
INSERT INTO CenaAuta (automobil_id, datum_od, cena) VALUES (13, DATEADD(DAY, 13, '2026-01-01'), 14750.00);
INSERT INTO CenaAuta (automobil_id, datum_od, cena) VALUES (14, DATEADD(DAY, 14, '2026-01-01'), 15500.00);
INSERT INTO CenaAuta (automobil_id, datum_od, cena) VALUES (15, DATEADD(DAY, 15, '2026-01-01'), 16250.00);
INSERT INTO CenaAuta (automobil_id, datum_od, cena) VALUES (16, DATEADD(DAY, 16, '2026-01-01'), 17000.00);
INSERT INTO CenaAuta (automobil_id, datum_od, cena) VALUES (17, DATEADD(DAY, 17, '2026-01-01'), 17750.00);
INSERT INTO CenaAuta (automobil_id, datum_od, cena) VALUES (18, DATEADD(DAY, 18, '2026-01-01'), 18500.00);
INSERT INTO CenaAuta (automobil_id, datum_od, cena) VALUES (19, DATEADD(DAY, 19, '2026-01-01'), 19250.00);
INSERT INTO CenaAuta (automobil_id, datum_od, cena) VALUES (20, DATEADD(DAY, 20, '2026-01-01'), 20000.00);
INSERT INTO CenaAuta (automobil_id, datum_od, cena) VALUES (21, DATEADD(DAY, 21, '2026-01-01'), 20750.00);
INSERT INTO CenaAuta (automobil_id, datum_od, cena) VALUES (22, DATEADD(DAY, 22, '2026-01-01'), 21500.00);
INSERT INTO CenaAuta (automobil_id, datum_od, cena) VALUES (23, DATEADD(DAY, 23, '2026-01-01'), 22250.00);
INSERT INTO CenaAuta (automobil_id, datum_od, cena) VALUES (24, DATEADD(DAY, 24, '2026-01-01'), 23000.00);
INSERT INTO CenaAuta (automobil_id, datum_od, cena) VALUES (25, DATEADD(DAY, 25, '2026-01-01'), 23750.00);
INSERT INTO CenaAuta (automobil_id, datum_od, cena) VALUES (26, DATEADD(DAY, 26, '2026-01-01'), 24500.00);
INSERT INTO CenaAuta (automobil_id, datum_od, cena) VALUES (27, DATEADD(DAY, 27, '2026-01-01'), 25250.00);
INSERT INTO CenaAuta (automobil_id, datum_od, cena) VALUES (28, DATEADD(DAY, 28, '2026-01-01'), 26000.00);
INSERT INTO CenaAuta (automobil_id, datum_od, cena) VALUES (29, DATEADD(DAY, 29, '2026-01-01'), 26750.00);
INSERT INTO CenaAuta (automobil_id, datum_od, cena) VALUES (30, DATEADD(DAY, 30, '2026-01-01'), 27500.00);
INSERT INTO CenaAuta (automobil_id, datum_od, cena) VALUES (31, DATEADD(DAY, 31, '2026-01-01'), 28250.00);
INSERT INTO CenaAuta (automobil_id, datum_od, cena) VALUES (32, DATEADD(DAY, 32, '2026-01-01'), 29000.00);
INSERT INTO CenaAuta (automobil_id, datum_od, cena) VALUES (33, DATEADD(DAY, 33, '2026-01-01'), 29750.00);
INSERT INTO CenaAuta (automobil_id, datum_od, cena) VALUES (34, DATEADD(DAY, 34, '2026-01-01'), 30500.00);
INSERT INTO CenaAuta (automobil_id, datum_od, cena) VALUES (35, DATEADD(DAY, 35, '2026-01-01'), 31250.00);
INSERT INTO CenaAuta (automobil_id, datum_od, cena) VALUES (36, DATEADD(DAY, 36, '2026-01-01'), 32000.00);
INSERT INTO CenaAuta (automobil_id, datum_od, cena) VALUES (37, DATEADD(DAY, 37, '2026-01-01'), 32750.00);
INSERT INTO CenaAuta (automobil_id, datum_od, cena) VALUES (38, DATEADD(DAY, 38, '2026-01-01'), 33500.00);
INSERT INTO CenaAuta (automobil_id, datum_od, cena) VALUES (39, DATEADD(DAY, 39, '2026-01-01'), 34250.00);
INSERT INTO CenaAuta (automobil_id, datum_od, cena) VALUES (40, DATEADD(DAY, 40, '2026-01-01'), 35000.00);

INSERT INTO Predaj (automobil_id, stary_majitel_id, novy_majitel_id, datum_predaja, cena) VALUES (1, 1, 2, DATEADD(DAY, 1, '2026-06-01'), 6800.00);
INSERT INTO Predaj (automobil_id, stary_majitel_id, novy_majitel_id, datum_predaja, cena) VALUES (2, 2, 3, DATEADD(DAY, 2, '2026-06-01'), 7600.00);
INSERT INTO Predaj (automobil_id, stary_majitel_id, novy_majitel_id, datum_predaja, cena) VALUES (3, 3, 4, DATEADD(DAY, 3, '2026-06-01'), 8400.00);
INSERT INTO Predaj (automobil_id, stary_majitel_id, novy_majitel_id, datum_predaja, cena) VALUES (4, 4, 5, DATEADD(DAY, 4, '2026-06-01'), 9200.00);
INSERT INTO Predaj (automobil_id, stary_majitel_id, novy_majitel_id, datum_predaja, cena) VALUES (5, 5, 6, DATEADD(DAY, 5, '2026-06-01'), 10000.00);
INSERT INTO Predaj (automobil_id, stary_majitel_id, novy_majitel_id, datum_predaja, cena) VALUES (6, 6, 7, DATEADD(DAY, 6, '2026-06-01'), 10800.00);
INSERT INTO Predaj (automobil_id, stary_majitel_id, novy_majitel_id, datum_predaja, cena) VALUES (7, 7, 8, DATEADD(DAY, 7, '2026-06-01'), 11600.00);
INSERT INTO Predaj (automobil_id, stary_majitel_id, novy_majitel_id, datum_predaja, cena) VALUES (8, 8, 9, DATEADD(DAY, 8, '2026-06-01'), 12400.00);
INSERT INTO Predaj (automobil_id, stary_majitel_id, novy_majitel_id, datum_predaja, cena) VALUES (9, 9, 10, DATEADD(DAY, 9, '2026-06-01'), 13200.00);
INSERT INTO Predaj (automobil_id, stary_majitel_id, novy_majitel_id, datum_predaja, cena) VALUES (10, 10, 11, DATEADD(DAY, 10, '2026-06-01'), 14000.00);
INSERT INTO Predaj (automobil_id, stary_majitel_id, novy_majitel_id, datum_predaja, cena) VALUES (11, 11, 12, DATEADD(DAY, 11, '2026-06-01'), 14800.00);
INSERT INTO Predaj (automobil_id, stary_majitel_id, novy_majitel_id, datum_predaja, cena) VALUES (12, 12, 13, DATEADD(DAY, 12, '2026-06-01'), 15600.00);
INSERT INTO Predaj (automobil_id, stary_majitel_id, novy_majitel_id, datum_predaja, cena) VALUES (13, 13, 14, DATEADD(DAY, 13, '2026-06-01'), 16400.00);
INSERT INTO Predaj (automobil_id, stary_majitel_id, novy_majitel_id, datum_predaja, cena) VALUES (14, 14, 15, DATEADD(DAY, 14, '2026-06-01'), 17200.00);
INSERT INTO Predaj (automobil_id, stary_majitel_id, novy_majitel_id, datum_predaja, cena) VALUES (15, 15, 16, DATEADD(DAY, 15, '2026-06-01'), 18000.00);
INSERT INTO Predaj (automobil_id, stary_majitel_id, novy_majitel_id, datum_predaja, cena) VALUES (16, 16, 17, DATEADD(DAY, 16, '2026-06-01'), 18800.00);
INSERT INTO Predaj (automobil_id, stary_majitel_id, novy_majitel_id, datum_predaja, cena) VALUES (17, 17, 18, DATEADD(DAY, 17, '2026-06-01'), 19600.00);
INSERT INTO Predaj (automobil_id, stary_majitel_id, novy_majitel_id, datum_predaja, cena) VALUES (18, 18, 19, DATEADD(DAY, 18, '2026-06-01'), 20400.00);
INSERT INTO Predaj (automobil_id, stary_majitel_id, novy_majitel_id, datum_predaja, cena) VALUES (19, 19, 20, DATEADD(DAY, 19, '2026-06-01'), 21200.00);
INSERT INTO Predaj (automobil_id, stary_majitel_id, novy_majitel_id, datum_predaja, cena) VALUES (20, 20, 21, DATEADD(DAY, 20, '2026-06-01'), 22000.00);
INSERT INTO Predaj (automobil_id, stary_majitel_id, novy_majitel_id, datum_predaja, cena) VALUES (21, 21, 22, DATEADD(DAY, 21, '2026-06-01'), 22800.00);
INSERT INTO Predaj (automobil_id, stary_majitel_id, novy_majitel_id, datum_predaja, cena) VALUES (22, 22, 23, DATEADD(DAY, 22, '2026-06-01'), 23600.00);
INSERT INTO Predaj (automobil_id, stary_majitel_id, novy_majitel_id, datum_predaja, cena) VALUES (23, 23, 24, DATEADD(DAY, 23, '2026-06-01'), 24400.00);
INSERT INTO Predaj (automobil_id, stary_majitel_id, novy_majitel_id, datum_predaja, cena) VALUES (24, 24, 25, DATEADD(DAY, 24, '2026-06-01'), 25200.00);
INSERT INTO Predaj (automobil_id, stary_majitel_id, novy_majitel_id, datum_predaja, cena) VALUES (25, 25, 26, DATEADD(DAY, 25, '2026-06-01'), 26000.00);
INSERT INTO Predaj (automobil_id, stary_majitel_id, novy_majitel_id, datum_predaja, cena) VALUES (26, 26, 27, DATEADD(DAY, 26, '2026-06-01'), 26800.00);
INSERT INTO Predaj (automobil_id, stary_majitel_id, novy_majitel_id, datum_predaja, cena) VALUES (27, 27, 28, DATEADD(DAY, 27, '2026-06-01'), 27600.00);
INSERT INTO Predaj (automobil_id, stary_majitel_id, novy_majitel_id, datum_predaja, cena) VALUES (28, 28, 29, DATEADD(DAY, 28, '2026-06-01'), 28400.00);
INSERT INTO Predaj (automobil_id, stary_majitel_id, novy_majitel_id, datum_predaja, cena) VALUES (29, 29, 30, DATEADD(DAY, 29, '2026-06-01'), 29200.00);
INSERT INTO Predaj (automobil_id, stary_majitel_id, novy_majitel_id, datum_predaja, cena) VALUES (30, 30, 31, DATEADD(DAY, 30, '2026-06-01'), 30000.00);
INSERT INTO Predaj (automobil_id, stary_majitel_id, novy_majitel_id, datum_predaja, cena) VALUES (31, 31, 32, DATEADD(DAY, 31, '2026-06-01'), 30800.00);
INSERT INTO Predaj (automobil_id, stary_majitel_id, novy_majitel_id, datum_predaja, cena) VALUES (32, 32, 33, DATEADD(DAY, 32, '2026-06-01'), 31600.00);
INSERT INTO Predaj (automobil_id, stary_majitel_id, novy_majitel_id, datum_predaja, cena) VALUES (33, 33, 34, DATEADD(DAY, 33, '2026-06-01'), 32400.00);
INSERT INTO Predaj (automobil_id, stary_majitel_id, novy_majitel_id, datum_predaja, cena) VALUES (34, 34, 35, DATEADD(DAY, 34, '2026-06-01'), 33200.00);
INSERT INTO Predaj (automobil_id, stary_majitel_id, novy_majitel_id, datum_predaja, cena) VALUES (35, 35, 36, DATEADD(DAY, 35, '2026-06-01'), 34000.00);
INSERT INTO Predaj (automobil_id, stary_majitel_id, novy_majitel_id, datum_predaja, cena) VALUES (36, 36, 37, DATEADD(DAY, 36, '2026-06-01'), 34800.00);
INSERT INTO Predaj (automobil_id, stary_majitel_id, novy_majitel_id, datum_predaja, cena) VALUES (37, 37, 38, DATEADD(DAY, 37, '2026-06-01'), 35600.00);
INSERT INTO Predaj (automobil_id, stary_majitel_id, novy_majitel_id, datum_predaja, cena) VALUES (38, 38, 39, DATEADD(DAY, 38, '2026-06-01'), 36400.00);
INSERT INTO Predaj (automobil_id, stary_majitel_id, novy_majitel_id, datum_predaja, cena) VALUES (39, 39, 40, DATEADD(DAY, 39, '2026-06-01'), 37200.00);
INSERT INTO Predaj (automobil_id, stary_majitel_id, novy_majitel_id, datum_predaja, cena) VALUES (40, 40, 1, DATEADD(DAY, 40, '2026-06-01'), 38000.00);

INSERT INTO Uver (automobil_id, majitel_id, suma, urok, datum_zaciatku, datum_konca) VALUES (1, 1, 4000.00, 4.50, DATEADD(DAY, 1, '2026-02-01'), DATEADD(YEAR, 2, DATEADD(DAY, 1, '2026-02-01')));
INSERT INTO Uver (automobil_id, majitel_id, suma, urok, datum_zaciatku, datum_konca) VALUES (2, 2, 5000.00, 5.50, DATEADD(DAY, 2, '2026-02-01'), DATEADD(YEAR, 2, DATEADD(DAY, 2, '2026-02-01')));
INSERT INTO Uver (automobil_id, majitel_id, suma, urok, datum_zaciatku, datum_konca) VALUES (3, 3, 6000.00, 6.50, DATEADD(DAY, 3, '2026-02-01'), DATEADD(YEAR, 2, DATEADD(DAY, 3, '2026-02-01')));
INSERT INTO Uver (automobil_id, majitel_id, suma, urok, datum_zaciatku, datum_konca) VALUES (4, 4, 7000.00, 7.50, DATEADD(DAY, 4, '2026-02-01'), DATEADD(YEAR, 2, DATEADD(DAY, 4, '2026-02-01')));
INSERT INTO Uver (automobil_id, majitel_id, suma, urok, datum_zaciatku, datum_konca) VALUES (5, 5, 8000.00, 3.50, DATEADD(DAY, 5, '2026-02-01'), DATEADD(YEAR, 2, DATEADD(DAY, 5, '2026-02-01')));
INSERT INTO Uver (automobil_id, majitel_id, suma, urok, datum_zaciatku, datum_konca) VALUES (6, 6, 9000.00, 4.50, DATEADD(DAY, 6, '2026-02-01'), DATEADD(YEAR, 2, DATEADD(DAY, 6, '2026-02-01')));
INSERT INTO Uver (automobil_id, majitel_id, suma, urok, datum_zaciatku, datum_konca) VALUES (7, 7, 10000.00, 5.50, DATEADD(DAY, 7, '2026-02-01'), DATEADD(YEAR, 2, DATEADD(DAY, 7, '2026-02-01')));
INSERT INTO Uver (automobil_id, majitel_id, suma, urok, datum_zaciatku, datum_konca) VALUES (8, 8, 11000.00, 6.50, DATEADD(DAY, 8, '2026-02-01'), DATEADD(YEAR, 2, DATEADD(DAY, 8, '2026-02-01')));
INSERT INTO Uver (automobil_id, majitel_id, suma, urok, datum_zaciatku, datum_konca) VALUES (9, 9, 12000.00, 7.50, DATEADD(DAY, 9, '2026-02-01'), DATEADD(YEAR, 2, DATEADD(DAY, 9, '2026-02-01')));
INSERT INTO Uver (automobil_id, majitel_id, suma, urok, datum_zaciatku, datum_konca) VALUES (10, 10, 13000.00, 3.50, DATEADD(DAY, 10, '2026-02-01'), DATEADD(YEAR, 2, DATEADD(DAY, 10, '2026-02-01')));
INSERT INTO Uver (automobil_id, majitel_id, suma, urok, datum_zaciatku, datum_konca) VALUES (11, 11, 14000.00, 4.50, DATEADD(DAY, 11, '2026-02-01'), DATEADD(YEAR, 2, DATEADD(DAY, 11, '2026-02-01')));
INSERT INTO Uver (automobil_id, majitel_id, suma, urok, datum_zaciatku, datum_konca) VALUES (12, 12, 15000.00, 5.50, DATEADD(DAY, 12, '2026-02-01'), DATEADD(YEAR, 2, DATEADD(DAY, 12, '2026-02-01')));
INSERT INTO Uver (automobil_id, majitel_id, suma, urok, datum_zaciatku, datum_konca) VALUES (13, 13, 16000.00, 6.50, DATEADD(DAY, 13, '2026-02-01'), DATEADD(YEAR, 2, DATEADD(DAY, 13, '2026-02-01')));
INSERT INTO Uver (automobil_id, majitel_id, suma, urok, datum_zaciatku, datum_konca) VALUES (14, 14, 17000.00, 7.50, DATEADD(DAY, 14, '2026-02-01'), DATEADD(YEAR, 2, DATEADD(DAY, 14, '2026-02-01')));
INSERT INTO Uver (automobil_id, majitel_id, suma, urok, datum_zaciatku, datum_konca) VALUES (15, 15, 18000.00, 3.50, DATEADD(DAY, 15, '2026-02-01'), DATEADD(YEAR, 2, DATEADD(DAY, 15, '2026-02-01')));
INSERT INTO Uver (automobil_id, majitel_id, suma, urok, datum_zaciatku, datum_konca) VALUES (16, 16, 19000.00, 4.50, DATEADD(DAY, 16, '2026-02-01'), DATEADD(YEAR, 2, DATEADD(DAY, 16, '2026-02-01')));
INSERT INTO Uver (automobil_id, majitel_id, suma, urok, datum_zaciatku, datum_konca) VALUES (17, 17, 20000.00, 5.50, DATEADD(DAY, 17, '2026-02-01'), DATEADD(YEAR, 2, DATEADD(DAY, 17, '2026-02-01')));
INSERT INTO Uver (automobil_id, majitel_id, suma, urok, datum_zaciatku, datum_konca) VALUES (18, 18, 21000.00, 6.50, DATEADD(DAY, 18, '2026-02-01'), DATEADD(YEAR, 2, DATEADD(DAY, 18, '2026-02-01')));
INSERT INTO Uver (automobil_id, majitel_id, suma, urok, datum_zaciatku, datum_konca) VALUES (19, 19, 22000.00, 7.50, DATEADD(DAY, 19, '2026-02-01'), DATEADD(YEAR, 2, DATEADD(DAY, 19, '2026-02-01')));
INSERT INTO Uver (automobil_id, majitel_id, suma, urok, datum_zaciatku, datum_konca) VALUES (20, 20, 23000.00, 3.50, DATEADD(DAY, 20, '2026-02-01'), DATEADD(YEAR, 2, DATEADD(DAY, 20, '2026-02-01')));
INSERT INTO Uver (automobil_id, majitel_id, suma, urok, datum_zaciatku, datum_konca) VALUES (21, 21, 24000.00, 4.50, DATEADD(DAY, 21, '2026-02-01'), DATEADD(YEAR, 2, DATEADD(DAY, 21, '2026-02-01')));
INSERT INTO Uver (automobil_id, majitel_id, suma, urok, datum_zaciatku, datum_konca) VALUES (22, 22, 25000.00, 5.50, DATEADD(DAY, 22, '2026-02-01'), DATEADD(YEAR, 2, DATEADD(DAY, 22, '2026-02-01')));
INSERT INTO Uver (automobil_id, majitel_id, suma, urok, datum_zaciatku, datum_konca) VALUES (23, 23, 26000.00, 6.50, DATEADD(DAY, 23, '2026-02-01'), DATEADD(YEAR, 2, DATEADD(DAY, 23, '2026-02-01')));
INSERT INTO Uver (automobil_id, majitel_id, suma, urok, datum_zaciatku, datum_konca) VALUES (24, 24, 27000.00, 7.50, DATEADD(DAY, 24, '2026-02-01'), DATEADD(YEAR, 2, DATEADD(DAY, 24, '2026-02-01')));
INSERT INTO Uver (automobil_id, majitel_id, suma, urok, datum_zaciatku, datum_konca) VALUES (25, 25, 28000.00, 3.50, DATEADD(DAY, 25, '2026-02-01'), DATEADD(YEAR, 2, DATEADD(DAY, 25, '2026-02-01')));
INSERT INTO Uver (automobil_id, majitel_id, suma, urok, datum_zaciatku, datum_konca) VALUES (26, 26, 29000.00, 4.50, DATEADD(DAY, 26, '2026-02-01'), DATEADD(YEAR, 2, DATEADD(DAY, 26, '2026-02-01')));
INSERT INTO Uver (automobil_id, majitel_id, suma, urok, datum_zaciatku, datum_konca) VALUES (27, 27, 30000.00, 5.50, DATEADD(DAY, 27, '2026-02-01'), DATEADD(YEAR, 2, DATEADD(DAY, 27, '2026-02-01')));
INSERT INTO Uver (automobil_id, majitel_id, suma, urok, datum_zaciatku, datum_konca) VALUES (28, 28, 31000.00, 6.50, DATEADD(DAY, 28, '2026-02-01'), DATEADD(YEAR, 2, DATEADD(DAY, 28, '2026-02-01')));
INSERT INTO Uver (automobil_id, majitel_id, suma, urok, datum_zaciatku, datum_konca) VALUES (29, 29, 32000.00, 7.50, DATEADD(DAY, 29, '2026-02-01'), DATEADD(YEAR, 2, DATEADD(DAY, 29, '2026-02-01')));
INSERT INTO Uver (automobil_id, majitel_id, suma, urok, datum_zaciatku, datum_konca) VALUES (30, 30, 33000.00, 3.50, DATEADD(DAY, 30, '2026-02-01'), DATEADD(YEAR, 2, DATEADD(DAY, 30, '2026-02-01')));
INSERT INTO Uver (automobil_id, majitel_id, suma, urok, datum_zaciatku, datum_konca) VALUES (31, 31, 34000.00, 4.50, DATEADD(DAY, 31, '2026-02-01'), DATEADD(YEAR, 2, DATEADD(DAY, 31, '2026-02-01')));
INSERT INTO Uver (automobil_id, majitel_id, suma, urok, datum_zaciatku, datum_konca) VALUES (32, 32, 35000.00, 5.50, DATEADD(DAY, 32, '2026-02-01'), DATEADD(YEAR, 2, DATEADD(DAY, 32, '2026-02-01')));
INSERT INTO Uver (automobil_id, majitel_id, suma, urok, datum_zaciatku, datum_konca) VALUES (33, 33, 36000.00, 6.50, DATEADD(DAY, 33, '2026-02-01'), DATEADD(YEAR, 2, DATEADD(DAY, 33, '2026-02-01')));
INSERT INTO Uver (automobil_id, majitel_id, suma, urok, datum_zaciatku, datum_konca) VALUES (34, 34, 37000.00, 7.50, DATEADD(DAY, 34, '2026-02-01'), DATEADD(YEAR, 2, DATEADD(DAY, 34, '2026-02-01')));
INSERT INTO Uver (automobil_id, majitel_id, suma, urok, datum_zaciatku, datum_konca) VALUES (35, 35, 38000.00, 3.50, DATEADD(DAY, 35, '2026-02-01'), DATEADD(YEAR, 2, DATEADD(DAY, 35, '2026-02-01')));
INSERT INTO Uver (automobil_id, majitel_id, suma, urok, datum_zaciatku, datum_konca) VALUES (36, 36, 39000.00, 4.50, DATEADD(DAY, 36, '2026-02-01'), DATEADD(YEAR, 2, DATEADD(DAY, 36, '2026-02-01')));
INSERT INTO Uver (automobil_id, majitel_id, suma, urok, datum_zaciatku, datum_konca) VALUES (37, 37, 40000.00, 5.50, DATEADD(DAY, 37, '2026-02-01'), DATEADD(YEAR, 2, DATEADD(DAY, 37, '2026-02-01')));
INSERT INTO Uver (automobil_id, majitel_id, suma, urok, datum_zaciatku, datum_konca) VALUES (38, 38, 41000.00, 6.50, DATEADD(DAY, 38, '2026-02-01'), DATEADD(YEAR, 2, DATEADD(DAY, 38, '2026-02-01')));
INSERT INTO Uver (automobil_id, majitel_id, suma, urok, datum_zaciatku, datum_konca) VALUES (39, 39, 42000.00, 7.50, DATEADD(DAY, 39, '2026-02-01'), DATEADD(YEAR, 2, DATEADD(DAY, 39, '2026-02-01')));
INSERT INTO Uver (automobil_id, majitel_id, suma, urok, datum_zaciatku, datum_konca) VALUES (40, 40, 43000.00, 3.50, DATEADD(DAY, 40, '2026-02-01'), DATEADD(YEAR, 2, DATEADD(DAY, 40, '2026-02-01')));

INSERT INTO Splatka (uver_id, datum_splatky, suma, uhradene) VALUES (1, DATEADD(MONTH, 1, '2026-02-01'), 175.00, 0);
INSERT INTO Splatka (uver_id, datum_splatky, suma, uhradene) VALUES (2, DATEADD(MONTH, 2, '2026-02-01'), 200.00, 0);
INSERT INTO Splatka (uver_id, datum_splatky, suma, uhradene) VALUES (3, DATEADD(MONTH, 3, '2026-02-01'), 225.00, 1);
INSERT INTO Splatka (uver_id, datum_splatky, suma, uhradene) VALUES (4, DATEADD(MONTH, 4, '2026-02-01'), 250.00, 0);
INSERT INTO Splatka (uver_id, datum_splatky, suma, uhradene) VALUES (5, DATEADD(MONTH, 5, '2026-02-01'), 275.00, 0);
INSERT INTO Splatka (uver_id, datum_splatky, suma, uhradene) VALUES (6, DATEADD(MONTH, 6, '2026-02-01'), 300.00, 1);
INSERT INTO Splatka (uver_id, datum_splatky, suma, uhradene) VALUES (7, DATEADD(MONTH, 7, '2026-02-01'), 325.00, 0);
INSERT INTO Splatka (uver_id, datum_splatky, suma, uhradene) VALUES (8, DATEADD(MONTH, 8, '2026-02-01'), 350.00, 0);
INSERT INTO Splatka (uver_id, datum_splatky, suma, uhradene) VALUES (9, DATEADD(MONTH, 9, '2026-02-01'), 375.00, 1);
INSERT INTO Splatka (uver_id, datum_splatky, suma, uhradene) VALUES (10, DATEADD(MONTH, 10, '2026-02-01'), 400.00, 0);
INSERT INTO Splatka (uver_id, datum_splatky, suma, uhradene) VALUES (11, DATEADD(MONTH, 11, '2026-02-01'), 425.00, 0);
INSERT INTO Splatka (uver_id, datum_splatky, suma, uhradene) VALUES (12, DATEADD(MONTH, 12, '2026-02-01'), 450.00, 1);
INSERT INTO Splatka (uver_id, datum_splatky, suma, uhradene) VALUES (13, DATEADD(MONTH, 13, '2026-02-01'), 475.00, 0);
INSERT INTO Splatka (uver_id, datum_splatky, suma, uhradene) VALUES (14, DATEADD(MONTH, 14, '2026-02-01'), 500.00, 0);
INSERT INTO Splatka (uver_id, datum_splatky, suma, uhradene) VALUES (15, DATEADD(MONTH, 15, '2026-02-01'), 525.00, 1);
INSERT INTO Splatka (uver_id, datum_splatky, suma, uhradene) VALUES (16, DATEADD(MONTH, 16, '2026-02-01'), 550.00, 0);
INSERT INTO Splatka (uver_id, datum_splatky, suma, uhradene) VALUES (17, DATEADD(MONTH, 17, '2026-02-01'), 575.00, 0);
INSERT INTO Splatka (uver_id, datum_splatky, suma, uhradene) VALUES (18, DATEADD(MONTH, 18, '2026-02-01'), 600.00, 1);
INSERT INTO Splatka (uver_id, datum_splatky, suma, uhradene) VALUES (19, DATEADD(MONTH, 19, '2026-02-01'), 625.00, 0);
INSERT INTO Splatka (uver_id, datum_splatky, suma, uhradene) VALUES (20, DATEADD(MONTH, 20, '2026-02-01'), 650.00, 0);
INSERT INTO Splatka (uver_id, datum_splatky, suma, uhradene) VALUES (21, DATEADD(MONTH, 21, '2026-02-01'), 675.00, 1);
INSERT INTO Splatka (uver_id, datum_splatky, suma, uhradene) VALUES (22, DATEADD(MONTH, 22, '2026-02-01'), 700.00, 0);
INSERT INTO Splatka (uver_id, datum_splatky, suma, uhradene) VALUES (23, DATEADD(MONTH, 23, '2026-02-01'), 725.00, 0);
INSERT INTO Splatka (uver_id, datum_splatky, suma, uhradene) VALUES (24, DATEADD(MONTH, 24, '2026-02-01'), 750.00, 1);
INSERT INTO Splatka (uver_id, datum_splatky, suma, uhradene) VALUES (25, DATEADD(MONTH, 25, '2026-02-01'), 775.00, 0);
INSERT INTO Splatka (uver_id, datum_splatky, suma, uhradene) VALUES (26, DATEADD(MONTH, 26, '2026-02-01'), 800.00, 0);
INSERT INTO Splatka (uver_id, datum_splatky, suma, uhradene) VALUES (27, DATEADD(MONTH, 27, '2026-02-01'), 825.00, 1);
INSERT INTO Splatka (uver_id, datum_splatky, suma, uhradene) VALUES (28, DATEADD(MONTH, 28, '2026-02-01'), 850.00, 0);
INSERT INTO Splatka (uver_id, datum_splatky, suma, uhradene) VALUES (29, DATEADD(MONTH, 29, '2026-02-01'), 875.00, 0);
INSERT INTO Splatka (uver_id, datum_splatky, suma, uhradene) VALUES (30, DATEADD(MONTH, 30, '2026-02-01'), 900.00, 1);
INSERT INTO Splatka (uver_id, datum_splatky, suma, uhradene) VALUES (31, DATEADD(MONTH, 31, '2026-02-01'), 925.00, 0);
INSERT INTO Splatka (uver_id, datum_splatky, suma, uhradene) VALUES (32, DATEADD(MONTH, 32, '2026-02-01'), 950.00, 0);
INSERT INTO Splatka (uver_id, datum_splatky, suma, uhradene) VALUES (33, DATEADD(MONTH, 33, '2026-02-01'), 975.00, 1);
INSERT INTO Splatka (uver_id, datum_splatky, suma, uhradene) VALUES (34, DATEADD(MONTH, 34, '2026-02-01'), 1000.00, 0);
INSERT INTO Splatka (uver_id, datum_splatky, suma, uhradene) VALUES (35, DATEADD(MONTH, 35, '2026-02-01'), 1025.00, 0);
INSERT INTO Splatka (uver_id, datum_splatky, suma, uhradene) VALUES (36, DATEADD(MONTH, 36, '2026-02-01'), 1050.00, 1);
INSERT INTO Splatka (uver_id, datum_splatky, suma, uhradene) VALUES (37, DATEADD(MONTH, 37, '2026-02-01'), 1075.00, 0);
INSERT INTO Splatka (uver_id, datum_splatky, suma, uhradene) VALUES (38, DATEADD(MONTH, 38, '2026-02-01'), 1100.00, 0);
INSERT INTO Splatka (uver_id, datum_splatky, suma, uhradene) VALUES (39, DATEADD(MONTH, 39, '2026-02-01'), 1125.00, 1);
INSERT INTO Splatka (uver_id, datum_splatky, suma, uhradene) VALUES (40, DATEADD(MONTH, 40, '2026-02-01'), 1150.00, 0);
GO

-- Views and Functions
-- =========================
-- VIEWS
-- =========================

CREATE OR ALTER VIEW vw_AutaMajitelia AS
SELECT a.id, a.VIN, mo.nazov AS model, m.meno, m.priezvisko
FROM Automobil a
INNER JOIN Model mo ON a.model_id = mo.id
INNER JOIN Majitel m ON a.majitel_id = m.id;
GO

CREATE OR ALTER VIEW vw_MajiteliaAuta AS
SELECT m.id, m.meno, m.priezvisko, a.VIN
FROM Majitel m
LEFT JOIN Automobil a ON m.id = a.majitel_id;
GO

CREATE OR ALTER VIEW vw_ZnackyAuta AS
SELECT z.id, z.nazov AS znacka, a.VIN, mo.nazov AS model
FROM Znacka z
LEFT JOIN Model mo ON z.id = mo.znacka_id
LEFT JOIN Automobil a ON mo.id = a.model_id;
GO


-- =========================
-- FUNCTIONS
-- =========================

CREATE OR ALTER FUNCTION fn_VekAuta(@rok INT)
RETURNS INT
AS
BEGIN
    RETURN YEAR(GETDATE()) - @rok;
END;
GO

CREATE OR ALTER FUNCTION fn_PocetAut(@majitel_id INT)
RETURNS INT
AS
BEGIN
    DECLARE @pocet INT;
    SELECT @pocet = COUNT(*) 
    FROM Automobil 
    WHERE majitel_id = @majitel_id;

    RETURN ISNULL(@pocet,0);
END;
GO


-- =========================
-- PROCEDURES
-- =========================

-- Drop procedures if they exist
IF OBJECT_ID('dbo.sp_PridajAuto', 'P') IS NOT NULL DROP PROCEDURE sp_PridajAuto;
IF OBJECT_ID('dbo.sp_PrepisAuto', 'P') IS NOT NULL DROP PROCEDURE sp_PrepisAuto;
GO

CREATE PROCEDURE sp_PridajAuto
    @VIN VARCHAR(17),
    @model_id INT,
    @rok INT,
    @majitel_id INT
AS
BEGIN
    INSERT INTO Automobil(VIN, model_id, rok, palivo_id, farba_id, prevodovka_id, karoseria_id, majitel_id, stav)
    VALUES (@VIN, @model_id, @rok, NULL, NULL, NULL, NULL, @majitel_id, 'AKTIVNE');
END;
GO

CREATE PROCEDURE sp_PrepisAuto
    @auto_id INT,
    @novy_majitel INT
AS
BEGIN
    UPDATE Automobil
    SET majitel_id = @novy_majitel
    WHERE id = @auto_id;
END;
GO


-- =========================
-- TRIGGERS
-- =========================

IF OBJECT_ID('dbo.trg_VIN', 'TR') IS NOT NULL
    DROP TRIGGER trg_VIN;
GO

-- Drop triggers if they exist
IF OBJECT_ID('dbo.trg_VIN', 'TR') IS NOT NULL
    DROP TRIGGER trg_VIN;
GO

IF OBJECT_ID('dbo.trg_Historia', 'TR') IS NOT NULL
    DROP TRIGGER trg_Historia;
GO

CREATE TRIGGER trg_VIN
ON Automobil
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM inserted WHERE LEN(VIN) <> 17)
    BEGIN
        RAISERROR('VIN musi mat 17 znakov',16,1);
        ROLLBACK TRANSACTION;
    END
END;
GO

CREATE TRIGGER trg_Historia
ON Automobil
AFTER UPDATE
AS
BEGIN
    INSERT INTO HistoriaVlastnictva(automobil_id, stary_majitel_id, novy_majitel_id, datum_zmeny)
    SELECT d.id, d.majitel_id, i.majitel_id, GETDATE()
    FROM inserted i
    JOIN deleted d ON i.id = d.id
    WHERE i.majitel_id <> d.majitel_id;
END;
GO

-- =========================
-- TEST SELECTS - Display Tables and Analysis
-- =========================

PRINT '============================================'
PRINT '=== i) DISPLAY CREATED TABLES ===';
PRINT '============================================'
GO

SELECT 'Majitel' AS TableName; SELECT * FROM Majitel;
GO
SELECT 'Znacka' AS TableName; SELECT * FROM Znacka;
GO
SELECT 'Model' AS TableName; SELECT * FROM Model;
GO
SELECT 'Automobil' AS TableName; SELECT * FROM Automobil;
GO
SELECT 'Poistovna' AS TableName; SELECT * FROM Poistovna;
GO
SELECT 'Poistenie' AS TableName; SELECT * FROM Poistenie;
GO
SELECT 'Palivo' AS TableName; SELECT * FROM Palivo;
GO
SELECT 'Farba' AS TableName; SELECT * FROM Farba;
GO
SELECT 'Prevodovka' AS TableName; SELECT * FROM Prevodovka;
GO
SELECT 'Karoseria' AS TableName; SELECT * FROM Karoseria;
GO
SELECT 'DruhServisu' AS TableName; SELECT * FROM DruhServisu;
GO
SELECT 'Servis' AS TableName; SELECT * FROM Servis;
GO
SELECT 'ServisnyUkon' AS TableName; SELECT * FROM ServisnyUkon;
GO
SELECT 'STKStanica' AS TableName; SELECT * FROM STKStanica;
GO
SELECT 'Kontrola' AS TableName; SELECT * FROM Kontrola;
GO
SELECT 'HistoriaVlastnictva' AS TableName; SELECT * FROM HistoriaVlastnictva;
GO
SELECT 'CenaAuta' AS TableName; SELECT * FROM CenaAuta;
GO
SELECT 'Predaj' AS TableName; SELECT * FROM Predaj;
GO
SELECT 'Uver' AS TableName; SELECT * FROM Uver;
GO
SELECT 'Splatka' AS TableName; SELECT * FROM Splatka;
GO

PRINT '============================================'
PRINT '=== n) AGGREGATE FUNCTIONS ===';
PRINT '============================================'
GO

-- COUNT, SUM, AVG, MIN, MAX functions
SELECT 
    COUNT(*) AS TotalMajitelia,
    COUNT(DISTINCT id) AS UniqueOwners
FROM Majitel;
GO

SELECT 
    COUNT(*) AS TotalAutomobily,
    COUNT(DISTINCT model_id) AS UniqueModels,
    MIN(rok) AS OldestYear,
    MAX(rok) AS NewestYear,
    AVG(rok) AS AverageYear
FROM Automobil;
GO

SELECT 
    COUNT(*) AS TotalServisnych,
    SUM(cena) AS TotalPrice,
    AVG(cena) AS AveragePrice,
    MIN(cena) AS MinPrice,
    MAX(cena) AS MaxPrice
FROM Servis;
GO

SELECT 
    COUNT(*) AS TotalPoisteni,
    COUNT(DISTINCT automobil_id) AS UniqueAutos
FROM Poistenie;
GO

SELECT 
    COUNT(*) AS TotalUverov,
    SUM(suma) AS TotalSuma,
    AVG(urok) AS AverageInterestRate,
    MIN(urok) AS MinInterestRate,
    MAX(urok) AS MaxInterestRate
FROM Uver;
GO

PRINT '============================================'
PRINT '=== o) COMPLEX QUERIES - WHERE, LIKE, IN ===';
PRINT '============================================'
GO

-- Complex Query 1: WHERE and LIKE - Cars with specific brand names
PRINT 'Query 1: Cars from brands containing "a" (WHERE, LIKE)';
SELECT a.id, a.VIN, z.nazov AS Brand, mo.nazov AS Model, a.rok, m.meno, m.priezvisko
FROM Automobil a
INNER JOIN Model mo ON a.model_id = mo.id
INNER JOIN Znacka z ON mo.znacka_id = z.id
INNER JOIN Majitel m ON a.majitel_id = m.id
WHERE z.nazov LIKE '%a%'
ORDER BY z.nazov;
GO

-- Complex Query 2: IN and WHERE - Active cars with specific fuel types
PRINT 'Query 2: Active cars with Benzin or Nafta (WHERE, IN)';
SELECT a.id, a.VIN, mo.nazov AS Model, p.nazov AS Fuel, a.rok, a.stav, m.meno, m.priezvisko
FROM Automobil a
INNER JOIN Model mo ON a.model_id = mo.id
INNER JOIN Majitel m ON a.majitel_id = m.id
LEFT JOIN Palivo p ON a.palivo_id = p.id
WHERE a.stav = 'AKTIVNE' AND p.nazov IN ('Benzin', 'Nafta')
ORDER BY mo.nazov;
GO

-- Complex Query 3: Multiple conditions - owners with multiple cars
PRINT 'Query 3: Owners with multiple cars and service records (WHERE, IN, COUNT)';
SELECT m.id, m.meno, m.priezvisko, m.email,
    COUNT(DISTINCT a.id) AS PocetAut,
    COUNT(DISTINCT s.id) AS PocetServisov
FROM Majitel m
LEFT JOIN Automobil a ON m.id = a.majitel_id
LEFT JOIN Servis s ON a.id = s.automobil_id
GROUP BY m.id, m.meno, m.priezvisko, m.email
HAVING COUNT(DISTINCT a.id) > 0
ORDER BY PocetAut DESC;
GO

PRINT '============================================'
PRINT '=== p) THREE VIEWS ===';
PRINT '============================================'
GO

PRINT 'View 1: vw_AutaMajitelia (INNER JOIN)';
SELECT * FROM vw_AutaMajitelia;
GO

PRINT 'View 2: vw_MajiteliaAuta (LEFT JOIN)';
SELECT * FROM vw_MajiteliaAuta;
GO

PRINT 'View 3: vw_ZnackyAuta (LEFT JOIN)';
SELECT * FROM vw_ZnackyAuta;
GO

PRINT '============================================'
PRINT '=== SUMMARY ===';
PRINT '============================================'
GO

SELECT 'Majitel' AS TableName, COUNT(*) AS RecordCount FROM Majitel
UNION ALL
SELECT 'Znacka', COUNT(*) FROM Znacka
UNION ALL
SELECT 'Model', COUNT(*) FROM Model
UNION ALL
SELECT 'Automobil', COUNT(*) FROM Automobil
UNION ALL
SELECT 'Poistovna', COUNT(*) FROM Poistovna
UNION ALL
SELECT 'Poistenie', COUNT(*) FROM Poistenie
UNION ALL
SELECT 'Palivo', COUNT(*) FROM Palivo
UNION ALL
SELECT 'Farba', COUNT(*) FROM Farba
UNION ALL
SELECT 'Prevodovka', COUNT(*) FROM Prevodovka
UNION ALL
SELECT 'Karoseria', COUNT(*) FROM Karoseria
UNION ALL
SELECT 'DruhServisu', COUNT(*) FROM DruhServisu
UNION ALL
SELECT 'Servis', COUNT(*) FROM Servis
UNION ALL
SELECT 'ServisnyUkon', COUNT(*) FROM ServisnyUkon
UNION ALL
SELECT 'STKStanica', COUNT(*) FROM STKStanica
UNION ALL
SELECT 'Kontrola', COUNT(*) FROM Kontrola
UNION ALL
SELECT 'HistoriaVlastnictva', COUNT(*) FROM HistoriaVlastnictva
UNION ALL
SELECT 'CenaAuta', COUNT(*) FROM CenaAuta
UNION ALL
SELECT 'Predaj', COUNT(*) FROM Predaj
UNION ALL
SELECT 'Uver', COUNT(*) FROM Uver
UNION ALL
SELECT 'Splatka', COUNT(*) FROM Splatka
ORDER BY TableName;
GO

PRINT 'Database setup complete!'
GO
