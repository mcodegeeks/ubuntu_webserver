### Deploy Application
* Create a Job
* Choose a Freestly project
* Edit an executable shell on build step
```
docker rm -f homepage
docker pull mcodegeeks/homepage
docker system prune -f
docker run --name homepage -p 5000:5000 -v data-volume:/data-volume -d --rm mcodegeeks/homepage
```
