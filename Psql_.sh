#!/bin/bash
psql -d hmdte -c 'GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO hmdte;'
psql -d hmdte -c 'GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO hmdte;'
psql hmdte < /usr/share/sowerphp/extensions/sowerphp/app/Module/Sistema/Module/Usuarios/Model/Sql/PostgreSQL/usuarios.sql
psql hmdte < /usr/share/sowerphp/extensions/sowerphp/app/Module/Sistema/Module/General/Model/Sql/moneda.sql
psql hmdte < /var/www/html/hmdte/website/Module/Sistema/Module/General/Model/Sql/PostgreSQL/actividad_economica.sql
psql hmdte < /usr/share/sowerphp/extensions/sowerphp/app/Module/Sistema/Module/General/Module/DivisionGeopolitica/Model/Sql/PostgreSQL/division_geopolitica.sql
psql hmdte < /var/www/html/hmdte/website/Module/Dte/Model/Sql/PostgreSQL.sql