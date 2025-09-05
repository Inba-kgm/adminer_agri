from django.shortcuts import render

# Create your views here.
from django.http import HttpResponseRedirect

def home(request):
    return HttpResponseRedirect("")  # Redirect to Adminer
