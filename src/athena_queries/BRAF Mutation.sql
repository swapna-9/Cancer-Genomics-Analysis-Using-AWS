SELECT 
    s.sample_source,
    s.location,
    s.tumor,
    s.normal,
    v.type,
    v.type_2,
    v.annotated,
    v.name
FROM 
    samples s
LEFT JOIN 
    vcf v 
ON 
    s.tumor = v.tumor
WHERE 
    name = 'BRAF';
