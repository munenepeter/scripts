#include <stdio.h>
#include <string.h>

#include <sys/statvfs.h>

#define DISK_SIZE() ({ \
    struct statvfs stat; \
    if (statvfs("/", &stat) != 0) { \
        -1; \
    } else { \
        stat.f_blocks * stat.f_frsize; /* size in bytes */ \
    } \
})

#define MAX_FILENAME_SIZE 255
#define MAX_ENTRIES 1024
#define MAX_INODES (DISK_SIZE() / 16384) // One inode for every 16 KB

struct DirectoryEntry {
    char  filename[MAX_FILENAME_SIZE];
    int   inode;
};

struct Directory {
    struct     DirectoryEntry entries[MAX_ENTRIES];
    int        entry_count;
};

// Structure to represent the block locations where file data is stored
typedef struct {
    int block_numbers[10]; // Simplified: Array to store block locations
    int block_count;       // Number of blocks allocated
} BlockLocations;

// Structure to represent file metadata
typedef struct {
    int             inode;               // Unique inode number
    int             file_permissions;    // Permissions (e.g., rw-r--r--)
    int             file_size;           // File size in bytes
    int             last_accessed;       // Timestamp of last access
    int             last_modified;       // Timestamp of last modification
    char            file_path[MAX_FILENAME_SIZE];
    Links           hard_links;          // Number of hard links
    BlockLocations  blocks;   // Locations of data blocks
} FileMetadata;

// Simplified structure to represent an inode
typedef struct {
    int inode;               // Inode number
    int reference_count;     // Number of references (hard links) to this inode
} Inode;

// Structure to represent the inode table
typedef struct {
    Inode inodes[MAX_INODES];      // Array to store inodes
    int   free_inodes;             // Number of free inodes
} InodeTable;

typedef struct{
    char username[255];
    char email[255];
    char password[255];
    int age;
} Row;

typedef struct {
    char instruction[255];
    int status;
} Statement;

void add_stmt(Statement *stmt, Row *row, int status) {
    sscanf(stmt->instruction, "Query: SELECT * FROM users WHERE username = '%s' AND email = '%s' AND password = '%s' AND age = %d", row->username, row->email, row->password, row->age);
    stmt->status = status;
}



int main() {
    struct Directory myDir = { .entry_count = 0 };
    Statement statement;

    struct Row row = {
        .username = 'peter',
        .email = 'peter@me.com',
        .password = 'password',
        .age = 42
    };

    add_stmt(&statement, row, 0);

    if (statement.status == 0) {
        printf("Query: SELECT * FROM users WHERE username = '%s' AND email = '%s' AND password = '%s' AND age = %d\n", row.username, row.email, row.password, row.age);
    }



    add_entry(&myDir, "file1.txt", 42);
    add_entry(&myDir, "file2.txt", 43);

    print_directory(&myDir);

    return 0;
}

void add_entry(struct Directory *dir, const char *filename, int inode) {
    if (dir->entry_count < MAX_ENTRIES) {

        //copy to the last entry
        strncpy(dir->entries[dir->entry_count].filename, filename, MAX_FILENAME_SIZE - 1);
       //         last entry in dir.filename,           "new file",     254
 
        // now we edit the newly saved file name
        dir->entries[dir->entry_count].filename[MAX_FILENAME_SIZE - 1] = '\0'; 
        //"new file\0"
        dir->entries[dir->entry_count].inode = inode;
        //set inode
        dir->entry_count++;

        //increament the entry count
    } else {
        printf("Directory is full!\n");
    }
}

void print_directory(const struct Directory *dir) {
    printf("Directory contents:\n");
    for (int i = 0; i < dir->entry_count; i++) {
        printf("%s -> inode %d\n", dir->entries[i].filename, dir->entries[i].inode);
    }
}