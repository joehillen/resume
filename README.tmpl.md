# Resume - $(get name)

*PDF version available [here]($(get links.Resume)joehillen-resume.pdf)*

$(get email)  
$(get location)

$(get about | sed 's/$/\n/' | fold -w 78 -s | trim | sed 's/$/  /g')
## History

$(for job in $(get 'history | keys | .[]'); do
  job_md "history[$job]"
  for client in $(get "history[$job].clients | keys[]"); do
    echo -n '#'
    job_md "history[$job].clients[$client]"
  done
done)

## Education

$(edu degree) ($(edu focus))  
$(edu school)  
Graduated: $(edu graduated)  

## Links

- <$(get links.Resume)>
- <$(get links.GitHub)>
- <$(get links.LinkedIn)>
- <$(get links.Keybase)>
