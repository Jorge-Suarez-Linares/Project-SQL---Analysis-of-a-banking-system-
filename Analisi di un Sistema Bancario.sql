/*[ENG]Creating a denormalized table for customer behavior analysis, based on transactional data and product ownership. 
The aim is to generate features for a supervised machine learning model.

[ITA]Creazione di una tabella denormalizzata per l'analisi del comportamento del cliente, 
basata su transazioni e possedimenti di prodotti. L'obiettivo è generare le caratteristiche (features)
per un modello di machine learning supervisionato.*/






/*Age
Number of outgoing transactions on all accounts
Number of incoming transactions on all accounts
Amount transacted outgoing on all accounts
Amount transacted incoming on all accounts
Total number of accounts owned
Number of accounts owned per type (an indicator per type)
Number of outgoing transactions per type (an indicator per type)
Number of incoming transactions per type (an indicator per type)
Amount transacted outgoing per account type (an indicator per type)
Amount transacted incoming per account type (an indicator per type)


Età
Numero di transazioni in uscita su tutti i conti
Numero di transazioni in entrata su tutti i conti
Importo transato in uscita su tutti i conti
Importo transato in entrata su tutti i conti
Numero totale di conti posseduti
Numero di conti posseduti per tipologia (un indicatore per tipo)
Numero di transazioni in uscita per tipologia (un indicatore per tipo)
Numero di transazioni in entrata per tipologia (un indicatore per tipo)
Importo transato in uscita per tipologia di conto (un indicatore per tipo)
Importo transato in entrata per tipologia di conto (un indicatore per tipo)*/

select * from banca.cliente
select * from banca.conto
select * from banca.tipo_conto
select * from banca.tipo_transazione
select * from banca.transazioni

-- Age / Età

create temporary table banca.age_clnt as
select clnt.id_cliente as id_clnt_age, 
round(datediff(current_date(), clnt.data_nascita)/365) as age
from banca.cliente clnt


create temporary table banca.conto_trans as 
select cnt.id_cliente,  

/* Numero di transazioni in uscita su tutti i conti
   Number of outgoing transactions on all accounts*/

count( case when tipo_trans.segno = '-' then 1 else 0 end) total_trans_out,  

/* Numero di transazioni in entrata su tutti i conti
   Number of incoming transactions on all accounts*/

count( case when tipo_trans.segno = '+' then 1 else 0 end) total_trans_in,  

/*Importo transato in uscita su tutti i conti
  Amount transacted outgoing on all accounts*/

round(sum(case when tipo_trans.segno="-" then tran.importo else 0 end),2) total_import_out, 

/*Importo transato in entrata su tutti i conti
  Amount transacted incoming on all accounts*/

round(sum(case when tipo_trans.segno="+" then tran.importo else 0 end),2) total_import_in,  

/* Numero totale di conti posseduti
   Total number of accounts owned*/

count(distinct cnt.id_conto) as total_bank_accounts,  


/* Numero di conti posseduti per tipologia (un indicatore per tipo)
   Number of accounts owned per type (an indicator per type)*/

count(distinct case when t_cnt.desc_tipo_conto = "Conto Base" then cnt.id_cliente end) as base_account, 
count(distinct case when t_cnt.desc_tipo_conto = "Conto Business" then cnt.id_cliente end) as business_account, 
count(distinct case when t_cnt.desc_tipo_conto = "Conto Privati" then cnt.id_cliente end) as private_account, 
count(distinct case when t_cnt.desc_tipo_conto = "Conto Famiglie" then cnt.id_cliente end) as family_account,  

/* Numero di transazioni in uscita per tipologia (un indicatore per tipo)
   Number of accounts owned per type (an indicator per type)*/

count(case when tipo_trans.desc_tipo_trans = "Acquisto su Amazon" then cnt.id_cliente end) as trans_out_amazon, 
count(case when tipo_trans.desc_tipo_trans = "Rata mutuo" then cnt.id_cliente end) as trans_out_installment, 
count(case when tipo_trans.desc_tipo_trans = "Hotel" then cnt.id_cliente end) as trans_out_hotel, 
count(case when tipo_trans.desc_tipo_trans = "Biglietto aereo" then cnt.id_cliente end) as trans_out_airplane, 
count(case when tipo_trans.desc_tipo_trans = "Supermercato" then cnt.id_cliente end) as trans_uscita_supermarket,  

/* Numero di transazioni in entrata per tipologia (un indicatore per tipo)
   Number of incoming transactions per type (an indicator per type)*/

count(case when tipo_trans.desc_tipo_trans = "Stipendio" then cnt.id_cliente end) as trans_in_salary, 
count(case when tipo_trans.desc_tipo_trans = "Pensione" then cnt.id_cliente end) as trans_in_pension, 
count(case when tipo_trans.desc_tipo_trans = "Dividendi" then cnt.id_cliente end) as trans_in_dividends,  


/*Importo transato in uscita per tipologia di conto (un indicatore per tipo)
  Importo transato in entrata per tipologia di conto (un indicatore per tipo)
  Amount transacted outgoing per account type (an indicator per type)
  Amount transacted incoming per account type (an indicator per type)*/
  
round(sum(case when tipo_trans.segno="-" and t_cnt.desc_tipo_conto = "Conto Base" then tran.importo else 0 end),2) import_trans_out_base, 
round(sum(case when tipo_trans.segno="+" and t_cnt.desc_tipo_conto = "Conto Base" then tran.importo else 0 end),2) import_trans_in_base, 
round(sum(case when tipo_trans.segno="-" and t_cnt.desc_tipo_conto = "Conto Business" then tran.importo else 0 end),2) import_trans_out_business, 
round(sum(case when tipo_trans.segno="+" and t_cnt.desc_tipo_conto = "Conto Business" then tran.importo else 0 end),2) import_trans_in_business,  
round(sum(case when tipo_trans.segno="-" and t_cnt.desc_tipo_conto = "Conto Privati" then tran.importo else 0 end),2) import_trans_out_private, 
round(sum(case when tipo_trans.segno="+" and t_cnt.desc_tipo_conto = "Conto Privati" then tran.importo else 0 end),2) import_trans_in_private, 
round(sum(case when tipo_trans.segno="-" and t_cnt.desc_tipo_conto = "Conto Famiglie" then tran.importo else 0 end),2) import_trans_out_family, 
round(sum(case when tipo_trans.segno="+" and t_cnt.desc_tipo_conto = "Conto Famiglie" then tran.importo else 0 end),2) import_trans_in_family 
  
from banca.conto cnt 
left join banca.tipo_conto t_cnt on cnt.id_tipo_conto = t_cnt.id_tipo_conto 
left join banca.transazioni tran on cnt.id_conto = tran.id_conto 
left join banca.tipo_transazione tipo_trans on tran.id_tipo_trans = tipo_trans.id_tipo_transazione 
group by 1 
order by 1;

/* Creazione della tabella finale 
   Creation of the final table*/
   
create table banca.table_final as
select *
from banca.age_clnt c_age
left join banca.conto_trans cnt_t
on c_age.id_clnt_age = cnt_t.id_cliente;

select * from banca.table_final










