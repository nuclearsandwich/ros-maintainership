SELECT 'Number of packages', COUNT(*) FROM packages;
SELECT 'Number of distros', COUNT(*) FROM distros;
SELECT 'Number of maintainers', COUNT(*) FROM maintainers;

CREATE TEMPORARY TABLE ranges (
	lower_bound INTEGER NOT NULL,
	upper_bound INTEGER NOT NULL,
	range TEXT UNIQUE NOT NULL
);

INSERT INTO ranges(range, lower_bound, upper_bound) VALUES
	('     0..1', 0, 1),
	('    2..10', 2, 10),
	('   11..50', 11, 50),
	('  51..150', 51, 150),
	(' 151..300', 151, 300),
	('301..1000', 301, 1000)

;

CREATE TEMPORARY VIEW package_counts_by_maintainer(maintainer_email, package_count) AS
	SELECT maintainer_email, COUNT(*) as package_count FROM distro_package_maintainers
  		GROUP BY maintainer_email ORDER BY package_count DESC;


select r.range, count(*) from ranges r inner join package_counts_by_maintainer pc ON pc.package_count between r.lower_bound and r.upper_bound group by r.range;
