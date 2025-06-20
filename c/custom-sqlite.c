#include <fcntl.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

typedef struct {
  char *buffer;
} InputBuffer;

typedef enum { EXECUTE_SUCCESS,
               EXECUTE_TABLE_FULL } ExecuteResult;

typedef enum {
  META_COMMAND_SUCCESS,
  META_COMMAND_UNRECOGNIZED_COMMAND
} MetaCommandResult;

typedef enum {
  PREPARE_SUCCESS,
  PREPARE_SYNTAX_ERROR,
  PREPARE_UNRECOGNIZED_STATEMENT
} PrepareResult;

typedef enum { STATEMENT_INSERT,
               STATEMENT_SELECT } StatementType;

#define COLUMN_USERNAME_SIZE 32
#define COLUMN_EMAIL_SIZE 255

typedef struct {
  int file_descriptor;
  uint32_t file_length;
  void *pages[TABLE_MAX_PAGES];
} Pager;

typedef struct {
  uint32_t id;
  char username[COLUMN_USERNAME_SIZE];
  char email[COLUMN_EMAIL_SIZE];
} Row;

typedef struct {
  StatementType type;
  Row row_to_insert; // only used by insert statement
} Statement;

#define size_of_attribute(Struct, Attribute) sizeof(((Struct *)0)->Attribute)

const uint32_t ID_SIZE = size_of_attribute(Row, id);
const uint32_t USERNAME_SIZE = size_of_attribute(Row, username);
const uint32_t EMAIL_SIZE = size_of_attribute(Row, email);
const uint32_t ID_OFFSET = 0;
const uint32_t USERNAME_OFFSET = ID_OFFSET + ID_SIZE;
const uint32_t EMAIL_OFFSET = USERNAME_OFFSET + USERNAME_SIZE;
const uint32_t ROW_SIZE = ID_SIZE + USERNAME_SIZE + EMAIL_SIZE;

const uint32_t PAGE_SIZE = 4096;
#define TABLE_MAX_PAGES 100
const uint32_t ROWS_PER_PAGE = PAGE_SIZE / ROW_SIZE;
const uint32_t TABLE_MAX_ROWS = ROWS_PER_PAGE * TABLE_MAX_PAGES;

typedef struct {
  uint32_t num_rows;
  void *pages[TABLE_MAX_PAGES];
} Table;

void print_row(Row *row) {
  printf("(%d, %s, %s)\n", row->id, row->username, row->email);
}

void serialize_row(Row *source, void *destination) {
  memcpy(destination + ID_OFFSET, &(source->id), ID_SIZE);
  memcpy(destination + USERNAME_OFFSET, &(source->username), USERNAME_SIZE);
  memcpy(destination + EMAIL_OFFSET, &(source->email), EMAIL_SIZE);
}

void deserialize_row(void *source, Row *destination) {
  memcpy(&(destination->id), source + ID_OFFSET, ID_SIZE);
  memcpy(&(destination->username), source + USERNAME_OFFSET, USERNAME_SIZE);
  memcpy(&(destination->email), source + EMAIL_OFFSET, EMAIL_SIZE);
}

void *row_slot(Table *table, uint32_t row_num) {
  uint32_t page_num = row_num / ROWS_PER_PAGE;
  void *page = table->pages[page_num];
  if (page == NULL) {
    // Allocate memory only when we try to access page
    page = table->pages[page_num] = malloc(PAGE_SIZE);
  }
  uint32_t row_offset = row_num % ROWS_PER_PAGE;
  uint32_t byte_offset = row_offset * ROW_SIZE;
  return page + byte_offset;
}

Table *new_table() {
  Table *table = (Table *)malloc(sizeof(Table));
  table->num_rows = 0;
  for (uint32_t i = 0; i < TABLE_MAX_PAGES; i++) {
    table->pages[i] = NULL;
  }
  return table;
}

void free_table(Table *table) {
  for (int i = 0; table->pages[i]; i++) {
    free(table->pages[i]);
  }
  free(table);
}

InputBuffer *new_input_buffer() {
  InputBuffer *input_buffer = (InputBuffer *)malloc(sizeof(InputBuffer));
  input_buffer->buffer = NULL;
  return input_buffer;
}
void close_input_buffer(InputBuffer *input_buffer) {
  free(input_buffer);
}

MetaCommandResult do_meta_command(InputBuffer *input_buffer, Table *table) {
  if (strcmp(input_buffer->buffer, ".exit") == 0) {
    close_input_buffer(input_buffer);
    free_table(table);
    exit(EXIT_SUCCESS);
  } else {
    return META_COMMAND_UNRECOGNIZED_COMMAND;
  }
}

PrepareResult prepare_statement(InputBuffer *input_buffer,
                                Statement *statement) {
  if (strncmp(input_buffer->buffer, "insert", 6) == 0) {
    statement->type = STATEMENT_INSERT;
    int args_assigned = sscanf(
        input_buffer->buffer, "insert %d %s %s", &(statement->row_to_insert.id),
        statement->row_to_insert.username, statement->row_to_insert.email);
    if (args_assigned < 3) {
      return PREPARE_SYNTAX_ERROR;
    }
    return PREPARE_SUCCESS;
  }
  if (strcmp(input_buffer->buffer, "select") == 0) {
    statement->type = STATEMENT_SELECT;
    return PREPARE_SUCCESS;
  }

  return PREPARE_UNRECOGNIZED_STATEMENT;
}

ExecuteResult execute_insert(Statement *statement, Table *table) {
  if (table->num_rows >= TABLE_MAX_ROWS) {
    void *node = get_page(table->pager, table->root_page_num);
    if ((*leaf_node_num_cells(node) >= LEAF_NODE_MAX_CELLS)) {
      return EXECUTE_TABLE_FULL;
    }

    Row *row_to_insert = &(statement->row_to_insert);
    Cursor *cursor = table_end(table);

    serialize_row(row_to_insert, cursor_value(cursor));
    table->num_rows += 1;
    leaf_node_insert(cursor, row_to_insert->id, row_to_insert);

    free(cursor);

    return EXECUTE_SUCCESS;
  }

  ExecuteResult execute_select(Statement * statement, Table * table) {
    Row row;
    for (uint32_t i = 0; i < table->num_rows; i++) {
      deserialize_row(row_slot(table, i), &row);
      print_row(&row);
    }
    return EXECUTE_SUCCESS;
  }

  ExecuteResult execute_statement(Statement * statement, Table * table) {
    switch (statement->type) {
    case (STATEMENT_INSERT):
      return execute_insert(statement, table);
    case (STATEMENT_SELECT):
      return execute_select(statement, table);
    }
  }

  int main(int argc, char *argv[]) {
    Table *table = new_table();
    InputBuffer *input_buffer = new_input_buffer();
    while (true) {
      print_prompt();
      read_input(input_buffer);

      if (strcmp(input_buffer->buffer, ".exit") == 0) {
        close_input_buffer(input_buffer);
        exit(EXIT_SUCCESS);
      } else {
        printf("Unrecognized command '%s'.\n", input_buffer->buffer);
        if (input_buffer->buffer[0] == '.') {
          switch (do_meta_command(input_buffer, table)) {
          case (META_COMMAND_SUCCESS):
            continue;
          case (META_COMMAND_UNRECOGNIZED_COMMAND):
            printf("Unrecognized command '%s'\n", input_buffer->buffer);
            continue;
          }
        }

        Statement statement;
        switch (prepare_statement(input_buffer, &statement)) {
        case (PREPARE_SUCCESS):
          break;
        case (PREPARE_SYNTAX_ERROR):
          printf("Syntax error. Could not parse statement.\n");
          continue;
        case (PREPARE_UNRECOGNIZED_STATEMENT):
          printf("Unrecognized keyword at start of '%s'.\n",
                 input_buffer->buffer);
          continue;
        }

        switch (execute_statement(&statement, table)) {
        case (EXECUTE_SUCCESS):
          printf("Executed.\n");
          break;
        case (EXECUTE_TABLE_FULL):
          printf("Error: Table full.\n");
          break;
        }
      }
    }

    Pager *pager_open(const char *filename) {
      int fd = open(filename,
                    O_RDWR |     // Read/Write mode
                        O_CREAT, // Create file if it does not exist
                    S_IWUSR |    // User write permission
                        S_IRUSR  // User read permission
      );

      if (fd == -1) {
        printf("Unable to open file\n");
        exit(EXIT_FAILURE);
      }

      off_t file_length = lseek(fd, 0, SEEK_END);

      Pager *pager = malloc(sizeof(Pager));
      pager->file_descriptor = fd;
      pager->file_length = file_length;

      for (uint32_t i = 0; i < TABLE_MAX_PAGES; i++) {
        pager->pages[i] = NULL;
      }

      return pager;
    }

    void *get_page(Pager * pager, uint32_t page_num) {
      if (page_num > TABLE_MAX_PAGES) {
        printf("Tried to fetch page number out of bounds. %d > %d\n", page_num,
               TABLE_MAX_PAGES);
        exit(EXIT_FAILURE);
      }

      if (pager->pages[page_num] == NULL) {
        // Cache miss. Allocate memory and load from file.
        void *page = malloc(PAGE_SIZE);
        uint32_t num_pages = pager->file_length / PAGE_SIZE;

        // We might save a partial page at the end of the file
        if (pager->file_length % PAGE_SIZE) {
          num_pages += 1;
        }

        if (page_num <= num_pages) {
          lseek(pager->file_descriptor, page_num * PAGE_SIZE, SEEK_SET);
          ssize_t bytes_read = read(pager->file_descriptor, page, PAGE_SIZE);
          if (bytes_read == -1) {
            printf("Error reading file: %d\n", errno);
            exit(EXIT_FAILURE);
          }
        }

        pager->pages[page_num] = page;
      }

      return pager->pages[page_num];
    }

    void pager_flush(Pager * pager, uint32_t page_num, uint32_t size) {
      if (pager->pages[page_num] == NULL) {
        printf("Tried to flush null page\n");
        exit(EXIT_FAILURE);
      }

      off_t offset = lseek(pager->file_descriptor, page_num * PAGE_SIZE, SEEK_SET);

      if (offset == -1) {
        printf("Error seeking: %d\n", errno);
        exit(EXIT_FAILURE);
      }

      ssize_t bytes_written =
          write(pager->file_descriptor, pager->pages[page_num], size);

      if (bytes_written == -1) {
        printf("Error writing: %d\n", errno);
        exit(EXIT_FAILURE);
      }
    }

    void leaf_node_insert(Cursor * cursor, uint32_t key, Row *value) {
      void *node = get_page(cursor->table->pager, cursor->page_num);

      uint32_t num_cells = *leaf_node_num_cells(node);
      if (num_cells >= LEAF_NODE_MAX_CELLS) {
        // Node full
        printf("Need to implement splitting a leaf node.\n");
        exit(EXIT_FAILURE);
      }

      if (cursor->cell_num < num_cells) {
        // Make room for new cell
        for (uint32_t i = num_cells; i > cursor->cell_num; i--) {
          memcpy(leaf_node_cell(node, i), leaf_node_cell(node, i - 1),
                 LEAF_NODE_CELL_SIZE);
        }
      }

      *(leaf_node_num_cells(node)) += 1;
      *(leaf_node_key(node, cursor->cell_num)) = key;
      serialize_row(value, leaf_node_value(node, cursor->cell_num));
    }
