SELECT 'Number of packages', COUNT(*) FROM packages;
SELECT 'Number of distros', COUNT(*) FROM distros;
SELECT 'Number of maintainers', COUNT(*) FROM maintainers;

SELECT maintainer_email, COUNT(*) FROM distro_package_maintainers
  GROUP BY maintainer_email ORDER BY COUNT(*) DESC;


