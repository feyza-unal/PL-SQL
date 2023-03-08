CREATE TABLE film
(
id int ,
title VARCHAR(50),
type VARCHAR(50),
length int
);
INSERT INTO film VALUES (1, 'Kuzuların Sessizliği', 'Korku',130);
INSERT INTO film VALUES (2, 'Esaretin Bedeli', 'Macera', 125);
INSERT INTO film VALUES (3, 'Kısa Film', 'Macera',40);
INSERT INTO film VALUES (4, 'Shrek', 'Animasyon',85);

CREATE TABLE actor
(
id int ,
isim VARCHAR(50),
soyisim VARCHAR(50)
);
INSERT INTO actor VALUES (1, 'Christian', 'Bale');
INSERT INTO actor VALUES (2, 'Kevin', 'Spacey');
INSERT INTO actor VALUES (3, 'Edward', 'Norton');


do $$  --> anonim oldugunu belirtmek icin

declare
	film_count integer :=0;
begin
	select count(*) --kac tane film varsa sayisini getirir
	into film_count  --Queryden gelen neticeyi film_count isimli degiskene atar
	from film; --tabloyu seciyorum
	
	raise notice 'The number of film is %',film_count; --% isareti yer tutucu olarak kullaniliyor
	
end $$

--*************  VARIABLE-CONSTANT  ****************

do $$
declare
	counter		integer :=1;
	first_name	varchar(50) := 'John';
	last_name	varchar(50) := 'Doe';
	payment		numeric(4,2) := 20.5; --toplam 4 karakter.virgulden sonra 2
begin
	raise notice '% % % has been paid % USD',
				 counter, --ilk %'e atar'
				 first_name, --ikinci %e atar
				 last_name, --ucuncu
				 payment; --dorduncu
end $$;

-- Task 1 : degiskenler olusturarak ekrana "Ahmet ve Mehmet beyler 120 tl ye bilet aldilar."
-- 			cumlesini yazdirin

do $$
declare
	price integer :=120;
	first_person varchar(50) :='Ahmet';
	second_person varchar(50) :='Mehmet';
begin
	raise notice '% ve % beyler % tl ye bilet aldilar.',
				first_person,
				second_person,
				price;
end $$			


-- ***************** BEKLETME KOMUTU ****************

do $$
declare 
	created_at time := now();
begin
	raise notice '%', created_at;
	perform pg_sleep(10); --calistiktan sonra 10 sn bekletmek icin
	raise notice '%', created_at;
end $$;

--> kod ayni anda calistigi icin ayni degeri gorduk. kodu sadece bekletip 10 sn sonra yazdi

--  ************** TABLODAN DATA TIPINI KOPYALAMA ***********
/*
		-> variable_name  table_name.column_name%type;
		->( Tablodaki datanın aynı data türünde variable oluşturmaya yarıyor)
*/

do $$
declare
	film_title film.title%type; --varchar -> data turunu bilmedigimiz icin dinamik yaptik (film.title%type)
								--> title'in data turu neyse onu yap
begin 
	--1 id li filmin ismini getirelim 
	select title 
	from film
	into film_title
	where id=1;
	
	raise notice 'Film title id 1: %' ,film_title;
end $$	

--  ************** IC ICE BLOK YAPILARI ***********
	
do $$
<<outher_block>>
declare
	counter integer :=0;
begin
	counter :=counter+1;
	raise notice 'The current value of counter is %',counter;
	
	declare
		counter integer :=0;
	begin 
		counter :=counter+10;
		raise notice 'Counter in the subBlock is %',counter;
		raise notice 'Counter in the outherBlock is %',outher_block.counter; --distakine ulasmak icin

	end;
	raise notice 'Counter in the outherBlock is %',counter;
	
end outher_block $$	;
	
/*
NOTICE:  The current value of counter is 1
NOTICE:  Counter in the subBlock is 10
NOTICE:  Counter in the outherBlock is 1
NOTICE:  Counter in the outherBlock is 1
*/


--  ************** ROW TYPE ***********

do $$
declare
	selected_actor actor%rowtype;  -- ilgili tablodaki ilgili degiskenin tipi
begin
	select *
	from actor
	into selected_actor --id,isim,soyisim
	where id=1;
	raise notice 'The actor name is % %',
			selected_actor.isim,
			selected_actor.soyisim;
end $$;	
	
	
--  ************* RECORD TYPE ***********
/*
		-> Row Type gibi çalışır ama record un tamamı değilde belli başlıkları almak
		istersek kullanılabilir
*/

do $$ 
declare
	rec record; --record data turunde rec isminde degisken olusturuldu
begin
	select id,title,type
	into rec
	from film
	where id=1;
	raise notice '% % %', rec.id, rec.title, rec.type;
end $$

--  ************** CONSTANT ************* --> degeri degistirilemeyen 

do $$
declare
	vat constant numeric :=0.1;
	net_price numeric :=20.5;
begin
	raise notice 'Satis fiyati : %', net_price*(1+vat);
	-- vat := 0.05; 
	-- constant bir ifadeyi ilk setleme işleminden sonra değer değiştirmeye çalışırsak hata alırız
end $$

-- constant bir ifadeye RunTime da değer verebilir miyim ???

do $$
declare
	start_at constant time := now();

begin
	raise notice 'bloğun çalışma zamanı : %', start_at;

end $$ ;

--  ************** CONTROL STRUCTERS *************

-- IF STATEMENT --
--syntax : 
/*
if cond. then
	statement;
end if;
*/

-- Task : 0 id li filmi bulalım eğer yoksa ekrana uyarı yazısı verelim
do $$
declare
	istenen_film film%rowtype; 
	istenen_filmId film.id%type :=10;
begin 
	select * from film
	into istenen_film
	where id = istenen_filmId; -->id'si 1 olan film
	
	if not found then--> eger veri gelmediyse
		raise notice 'Girdiginiz idli film bulunamadi : %', istenen_filmId;
	end if;	
	
end $$

-- IF THEN ELSE --
/*
if cond. then
	statement;
else
	alternative statement;
end if	
*/

-- Task : 1 idli film varsa title bilgisini yazınız yoksa uyarı yazısını ekrana basınız

do $$
declare
	istenen_film film%rowtype; 
	istenen_filmId film.id%type :=1;
begin 
	select * from film
	into istenen_film
	where id = istenen_filmId; 
	
	if found then
		raise notice 'Girdiginiz idli film : %', istenen_film.title;
	else
		raise notice 'Girdiginiz idli film bulunamadi : %', istenen_filmId;
	end if;	
	
end $$


-- IF THEN ELSE IF (nested)--
/*
if cond._1  then
	statement_1;
elseif cond_2 then
	statement_2;
elseif cond_3 then
	statement_3;
else
	statement_final
end if	
*/


/* Task : 1 idli film varsa;
		suresi 50 dk nin altinda ise short,
		50<length<120 medium,
		length>120 ise long yazalim
*/

do $$
declare
	x_film film%rowtype;
	len_description varchar(50);

begin 
	select * from film
	into x_film  -- v_film.id = 1  / v_film.title ='Kuzuların Sessizliği'
	where id = 1; 
	
	if not found then
		raise notice 'Bulunamadi';
	else
		if x_film.length > 0 and x_film.length <=50 then
			len_description ='short';
		
		elseif x_film.length>50 and x_film.length<120 then
			len_description ='medium';
			
		elseif x_film.length>120 then
			len_description='long';
		else
			len_description='tanimsiz';
		end if;
	raise notice '% filminin suresi: %',x_film.title,len_description;	
	end if;	
	
end $$

-- CASE STATEMENT --

-- syntax :
 /*
 	CASE search-expression
	 WHEN expression_1 [, expression_2,..] THEN
	 	statement
	 [..]
	 [ELSE
	 	else-statement]
	 END case;
 */


-- Task : Filmin türüne göre çocuklara uygun olup olmadığını ekrana yazalım

do $$
declare
	uyari varchar(50);
	tur film.type%type;
begin
	select type from film
	into tur
	where id = 1;
	
	if found then
		case tur
			when 'Korku' then uyari='cocuklar icin uygun degil';
			when 'Macera'then uyari='cocuklar icin uygun';
			when 'Animasyon' then uyari='cocuklar icin uygun';
			else uyari ='tanimsiz';
		end case;
		raise notice '%',uyari;
	end if;	
end $$




