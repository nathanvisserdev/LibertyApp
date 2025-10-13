-- RedefineTables
PRAGMA defer_foreign_keys=ON;
PRAGMA foreign_keys=OFF;
CREATE TABLE "new_Users" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "email" TEXT NOT NULL,
    "password" TEXT NOT NULL,
    "firstName" TEXT,
    "lastName" TEXT,
    "username" TEXT,
    "dateOfBirth" DATETIME,
    "gender" BOOLEAN,
    "phoneNumber" TEXT,
    "zipCode" TEXT,
    "photo" TEXT,
    "about" TEXT,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "isCreator" BOOLEAN NOT NULL DEFAULT false
);
INSERT INTO "new_Users" ("about", "createdAt", "dateOfBirth", "email", "firstName", "gender", "id", "lastName", "password", "phoneNumber", "photo", "username", "zipCode") SELECT "about", "createdAt", "dateOfBirth", "email", "firstName", "gender", "id", "lastName", "password", "phoneNumber", "photo", "username", "zipCode" FROM "Users";
DROP TABLE "Users";
ALTER TABLE "new_Users" RENAME TO "Users";
CREATE UNIQUE INDEX "Users_email_key" ON "Users"("email");
CREATE UNIQUE INDEX "Users_username_key" ON "Users"("username");
PRAGMA foreign_keys=ON;
PRAGMA defer_foreign_keys=OFF;
