<?php

class Blog {
    private \PDO $connection;

    public function __construct() {
        try {
            $this->connection = new \PDO(
                "mysql:host=127.0.0.1;dbname=blogs",
                'root',
                ''
            );
        } catch (\PDOException $e) {
            echo "Error" . $e->getMessage();
	    exit;
        }
    }
    public function allBloggers() {

        $selectQuery = "SELECT bloggerName FROM bloggers";
        $stmt = $this->connection->query($selectQuery);

        return $stmt->fetchAll(\PDO::FETCH_ASSOC);
    }
    public function insertBlog($bloggerId, $bloggerName, $blogSummary, $blogContent){

        $bloggerIdQuery = "SELECT bloggerId FROM bloggers WHERE bloggerName = ?";
        $stmt1 = $this->connection->prepare($bloggerIdQuery);

        if(!$stmt1->execute([$bloggerName])){
          echo "No blogger with '{$bloggerName}' is in our records!".PHP_EOL;
          return false;
        }

        $insertQuery = "INSERT INTO blogs (bloggerId, blogSummary, blogContent) VALUES(?,?,?)";
        $stmt1 = $this->connection->prepare($insertQuery);

        if(!$stmt1->execute([$bloggerId, $blogSummary, $blogContent])){
            echo "Something went wrong & Could not insert the blog, please try again later".PHP_EOL;
	    return false;
        }

        echo "Successfully Inserted a new Blog!".PHP_EOL;
	return true;
    }
   public function deleteBlog($blogId){

    	$bloggerIdQuery =  "SELECT bloggerId FROM bloggers WHERE bloggerId = ?";
	$stmt = $this->connection->prepare($bloggerIdQuery);

	if($stmt->execute([$bloggerId])){
	  echo "The blogger you're attempting to delete does not exist in the database";
	  return false;
	}

	$deleteQuery = "DELETE FROM bloggers WHERE `id` = ?"
	$stmt = $this->connection->prepare($deleteQuery);

	if(!$stmt->execute([$bloggerId])){
	  echo "Something happened we could not delete the speficied blogger!"
	  return false
	}

	echo "Successfully deleted the blogger!"
	return true;
   }
}

$blog =  new Blog();

//display all bloggers

foreach($blog->allBloggers() as $blogger){
    echo $blogger['bloggerName'] . PHP_EOL;
}

//Insert a new blog

$blog->insertBlog(54, 'max', "my blog summary","My content is here with all its glory");

//delete a blog

$blog->deleteBlog(54);
