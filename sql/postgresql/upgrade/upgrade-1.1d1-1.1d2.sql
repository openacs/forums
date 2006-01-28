-- propigate title and package_id to acs_objects.
create or replace function bookshelf_book__new (
  integer, -- book_id
  varchar, -- object_type
  integer, -- package_id
  varchar, -- isbn
  text,    -- book_author
  text,    -- book_title
  text,    -- main_entry
  text,    -- additional_entry
  text,    -- excerpt
  varchar, -- publish_status
  varchar, -- read_status
  date,    -- creation_date
  integer, -- creation_user
  varchar, -- creation_ip       
  integer  -- context_id
)
returns integer as '
declare
    p_book_id                       alias for $1;
    p_object_type                   alias for $2;
    p_package_id                    alias for $3;
    p_isbn                          alias for $4;
    p_book_author                   alias for $5;
    p_book_title                    alias for $6;
    p_main_entry                    alias for $7;
    p_additional_entry              alias for $8;
    p_excerpt                       alias for $9;
    p_publish_status                alias for $10;
    p_read_status                   alias for $11;
    p_creation_date                 alias for $12;
    p_creation_user                 alias for $13;
    p_creation_ip                   alias for $14;
    p_context_id                    alias for $15;
    v_book_id                       integer;
    v_book_no                       integer;
    v_creation_date                 date;
begin
    if p_creation_date is null then
        v_creation_date := now();
    else
        v_creation_date := p_creation_date;
    end if;

    v_book_id := acs_object__new(
        p_book_id,
        p_object_type,
        v_creation_date,
        p_creation_user,
        p_creation_ip,
        coalesce(p_context_id, p_package_id),
        ''t'',
        p_book_title,
        p_package_id
    );

    select coalesce(max(book_no),0) + 1
    into   v_book_no
    from   bookshelf_books
    where  package_id = p_package_id;

    insert into bookshelf_books
    (book_id, book_no, isbn, book_author, book_title, main_entry, additional_entry, excerpt, 
     publish_status, read_status, package_id)
    values
    (v_book_id, v_book_no, p_isbn, p_book_author, p_book_title, p_main_entry, p_additional_entry, p_excerpt,
     p_publish_status, p_read_status, p_package_id);

    return v_book_id;
end;
' language 'plpgsql';

