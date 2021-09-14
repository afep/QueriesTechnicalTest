--1. Escriba una query que le permita encontrar conceptos relacionados a la enfermedad seleccionada en la tabla "concepts"
SELECT concept_id,
concept_name,
domain_id,
--vocabulary_id,
--concept_class_id,
--standard_concept,
concept_code,
valid_start_date,
valid_end_date,
--invalid_reason
FROM `bigquery-public-data.cms_synthetic_patient_data_omop.concept` 
WHERE lower(concept_name) LIKE '%leukemia%' LIMIT 100

--2. Escriba una query que realice un join entre las tablas "person" y "death" agregando una variable booleana que indique si la persona aparece como fallecida.
SELECT p.person_id, 
IF( d.death_date is null, 'false', 'true') AS is_death, 
d.death_date 
FROM `bigquery-public-data.cms_synthetic_patient_data_omop.person` p
left join  `bigquery-public-data.cms_synthetic_patient_data_omop.death` d on p.person_id = d.person_id 
LIMIT 100

--3. Escriba una query que le entregue un conteo de muertes para cada uno de los conceptos relacionados a la enfermedad seleccionada haciendo un join entre la query anterior y las tablas de condition_era, drug_era y procedure_occurence según sea el caso
SELECT p.person_id, 
IF( d.death_date is null, 'false', 'true') AS is_death, 
d.death_date, 
d.death_type_concept_id,
c.concept_id,
count(c.concept_id),
ce.condition_era_id,
de.drug_era_id,
po.procedure_occurrence_id
FROM `bigquery-public-data.cms_synthetic_patient_data_omop.person` p
inner join `bigquery-public-data.cms_synthetic_patient_data_omop.death` d on p.person_id = d.person_id 
inner join `bigquery-public-data.cms_synthetic_patient_data_omop.concept` c on c.concept_id = d.death_type_concept_id
left join `bigquery-public-data.cms_synthetic_patient_data_omop.condition_era` ce on ce.person_id = p.person_id
left join `bigquery-public-data.cms_synthetic_patient_data_omop.drug_era` de on de.person_id = p.person_id
left join `bigquery-public-data.cms_synthetic_patient_data_omop.procedure_occurrence` po on po.person_id = p.person_id
where lower(c.concept_name) LIKE '%leukemia%'
group by 
p.person_id, 
d.death_date, 
d.death_type_concept_id,
c.concept_id,
ce.condition_era_id,
de.drug_era_id,
po.procedure_occurrence_id
LIMIT 1000

--4. Cree una visualización que permita identificar insights de tasa muerte: en el tiempo y por conceptos relacionados a la enfermedad seleccionada, y encontrar insigths usando entre otras las variables demográficas de la tabla person ID
SELECT p.person_id, 
p.year_of_birth,
d.death_date,
EXTRACT(YEAR FROM d.death_date) year_of_death,
EXTRACT(YEAR FROM d.death_date) - p.year_of_birth as age_of_death,
c.concept_name,
d.death_date,
l.county,
l.state,
FROM `bigquery-public-data.cms_synthetic_patient_data_omop.person` p
inner join `bigquery-public-data.cms_synthetic_patient_data_omop.death` d on p.person_id = d.person_id 
inner join `bigquery-public-data.cms_synthetic_patient_data_omop.location` l on p.location_id = l.location_id
inner join `bigquery-public-data.cms_synthetic_patient_data_omop.concept` c on c.concept_id = d.death_type_concept_id
order by year_of_death asc
LIMIT 100
